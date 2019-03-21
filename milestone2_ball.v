// Part 2 skeleton

module milestone2_ball
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn; //VGA reset low
	assign resetn = SW[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(~resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    	wire clear_signal, enable, enable_erase, enable_update, enable_fcounter, next_box, y_count_done, next_boxx;

    // Instansiate datapath
	// datapath d0(...);
		datapath d1(
		.clock(CLOCK_50), 
		.reset_n(resetn), 
		.enable(enable), 
		.enable_erase(enable_erase), 
		.enable_update(enable_update),
		.enable_fcounter(enable_fcounter),
		.x_out(x),
		.y_out(y),
		.colour_out(colour),
		.y_count_done(y_count_done)
	);
	
	control_draw c1(
		.go(~KEY[1]),
		.clock(CLOCK_50),
		.reset_n(resetn),
		.enable(enable),
		.write_en(writeEn),
		.enable_erase(enable_erase),
		.enable_update(enable_update),
		.enable_fcounter(enable_fcounter),
		.next_box(next_box),
		.y_count_done(y_count_done),
		.clear_sig(clear_signal)
	);

	 frame_counter f1(.clock(CLOCK_50), .enable(enable_fcounter), .resetn(resetn), .signal_out(next_box), .clear_sig(clear_signal));	 
    
endmodule

module datapath(clock, reset_n, x_out, y_out, enable_erase, enable_update, colour_out, enable, enable_fcounter,y_count_done);
    input clock, reset_n, enable, enable_erase, enable_update,enable_fcounter;
    output [7:0] x_out;
    output [6:0] y_out;
    output [2:0] colour_out;
	 output reg y_count_done;
    reg[7:0] x_inside; 
    reg[6:0] y_inside;
    reg[2:0] colour_inside;
	 reg vertical;
	 reg horizontal;
	 reg[1:0] x_count;
    reg[1:0] y_count;
	 
	 
	 collision col0(
		 .enable(enable_update), .clock(clock), 
		 .x(x_inside), .y(y_inside),
		 .flip_vertical(vertical), .flip_horizontal(horizontal)
	 );
	 
	 
    //Register for x, y, colour
    always @(posedge clock)
    begin
        if (reset_n)
        begin
            x_inside <= 8'b00000000;
            y_inside <= 60;
            colour_inside <= 3'b010;
//				vertical <= 1; //up
//				horizontal <= 1;//right
        end
        else
        begin
		  
            if (enable_erase) begin
	             colour_inside <= 3'b000;
					 end
				if(!enable_erase) begin
					 colour_inside <= 3'b010;
					end
					
            if (enable_update) begin
                //update x_insde, y_inside
					 if (vertical == 1'b1) begin
							y_inside <= y_inside - 1'b1;
					 end
					 if (horizontal == 1'b1) begin
					      x_inside <= x_inside + 1'b1;
					 end
					 if (vertical == 1'b0) begin
							y_inside <= y_inside + 1'b1;
					 end
					 if (horizontal == 1'b0) begin
					      x_inside <= x_inside - 1'b1;
					 end
					 
				end 
					 
        end
    end
   
	wire y_enable;
    assign y_enable = (x_count == 2'b11) ? 1'b1: 1'b0;
	 
    //Counter for x keeping the y coordinate the same.
    always @(posedge clock)
    begin
        if(reset_n)
        begin
            x_count <= 2'b000;
				y_count <= 2'b000;
		  end
 	     else if (enable == 1'b1)
	     begin
				
				if (y_enable == 1'b1) begin
					 
					 if (y_count == 2'b11) begin
							y_count_done <= 1'b1;
							y_count <= 2'b00;
					 end
				    else
					  begin
							y_count <= y_count + 1'b1;
							y_count_done <= 0;
					 end
				end
		  
	         if (x_count == 2'b11) begin
					x_count <= 2'b00;
					end
				else
				begin
					x_count <= x_count + 1'b1;
					y_count_done <= 0;
				end
			end
			
			if(y_count_done == 1 || enable_fcounter) begin
				x_count <= 2'b00;
				y_count <= 2'b00;
			end
	 end
    //Now fixing x, we add all the y pixels.

    
	 

    //Counter for y
//    always @(posedge clock)
//    begin
//        if(reset_n)
//        begin
//		  		//y_count_done <= 0;
//            y_count <= 2'b000;
//				//x_count <= 2'b000;
//		  end
//		  else if (y_enable == 1'b1 && enable == 1'b1)
//		  begin
//		      if (y_count == 2'b11) begin
//					 y_count_done <= 1'b1;
//  		          y_count <= 2'b00;
//	         end
//	         else
//	         begin
//		          y_count <= y_count + 1'b1;
//					 y_count_done <= 0;
// 	         end
//	    end
//    end
	 
//	 assign y_count_done = (y_count == 2'b11) ? 1 : 0;
	 
    assign colour_out = colour_inside;
    assign x_out = x_inside + x_count;
    assign y_out = y_inside + y_count;
endmodule

module control_draw(go, next_boxx, clock, reset_n, write_en, enable, enable_erase, enable_update, enable_fcounter, next_box, y_count_done, clear_sig);
	 input clock, reset_n, next_box, next_boxx, y_count_done, go;
	 output reg enable, write_en, enable_erase, enable_update, enable_fcounter, clear_sig;
	 
	 reg [3:0] curr_state, next_state;
	 
	 localparam  DRAW        = 4'd0,
                RESET_COUNTER   = 4'd1,
                ERASE        = 4'd2,
                UPDATE   = 4'd3,
					 RESET_COUNTERX = 4'd4;
					 
	// Next state logic aka our stRESET_COUNTERate table
    always@(*)
    begin: state_table 
            case (curr_state)
                DRAW: next_state = (y_count_done == 1) ? RESET_COUNTER: DRAW; 
                RESET_COUNTER: next_state = (next_box == 1) ? ERASE : RESET_COUNTER;
                ERASE: next_state  = (y_count_done == 1) ? UPDATE: ERASE;
					 //RESET_COUNTERX: next_state = (next_boxx == 1) ? DRAW : RESET_COUNTERX;
                UPDATE: next_state = DRAW; 
            default: next_state = DRAW;
        endcase
    end // state_table
	 
	 // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signalsmodule 
        // By default make all our signals 0
		  enable = 1'b0;
		  enable_erase = 1'b0;
		  write_en = 1'b0;
		  enable_update <= 0;
		  enable_fcounter <= 0;
		  clear_sig <= 0;
        case (curr_state)
            DRAW: begin
					 enable <= 1;
					 write_en <= 1;
                end
				RESET_COUNTER: begin
					 enable_fcounter <= 1;
                end
            ERASE: begin
                write_en <= 1;
					 enable <= 1;
					 enable_erase <= 1;
					 clear_sig <= 1;
                end
				UPDATE: begin
					 enable_update <= 1;
                end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
	 
	 // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(reset_n)
            curr_state <= DRAW;
        else
            curr_state <= next_state;
    end // state_FFS
endmodule

module combined_balls(clock, reset_n, x_out, y_out, colour_out);
	input clock, reset_n;
	wire enable, write_en, enable_erase, enable_update, go, next_boxx, enable_fcounter, next_box, y_count_done, clear_sig;
	output [7:0] x_out;
   output [6:0] y_out;
   output [2:0] colour_out;

	datapath d0(
		.clock(clock), 
		.reset_n(reset_n), 
		.enable(enable), 
		.enable_erase(enable_erase), 
		.enable_update(enable_update),
		.enable_fcounter(enable_fcounter),
		.x_out(x_out),
		.y_out(y_out),
		.colour_out(colour_out),
		.y_count_done(y_count_done)
	);
	
	control_draw c0(
		.clock(clock),
		.reset_n(reset_n),
		.enable(enable),
		.write_en(write_en),
		.enable_erase(enable_erase),
		.enable_update(enable_update),
		.enable_fcounter(enable_fcounter),
		.next_box(next_box),
		.y_count_done(y_count_done),
		.clear_sig(clear_sig),
		.next_boxx(next_boxx),
		.go(go)
	);

	 frame_counter f0(.clock(clock), .enable(enable_fcounter), .resetn(reset_n), .signal_out(next_box), .clear_sig(clear_sig));	 
endmodule

// Part 2 skeleton

module part2
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
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire enable_x, enable_y, enable_colour, enable;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
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
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	// datapath d0(...);
	datapath d0(.clock(CLOCK_50), .reset_n(resetn), .x_or_y(SW[6:0]), .colour(SW[9:7]), 
		.enable_x(enable_x), .enable_y(enable_y), 
		.enable_colour(enable_colour), .x_out(x),
		.y_out(y), .colour_out(colour), .enable(enable), .writeEn(writeEn), .enable_erase(~KEY[2]));
    // Instansiate FSM control
    // control c0(...);
	control c0(.clock(CLOCK_50), .reset_n(resetn), .go(KEY[3]), .enable(enable), .enable_x(enable_x),
       		.enable_y(enable_y), .enable_colour(enable_colour),.write_en(writeEn), .start(KEY[1]));
    
endmodule

module datapath(clock, reset_n, x_or_y, colour, enable_x, enable_y, enable_colour, x_out, y_out, colour_out, enable,writeEn, enable_erase);
    input clock, reset_n, enable_x, enable_y, enable_colour, enable,writeEn, enable_erase;
    input[6:0] x_or_y;
    input[2:0] colour;
    output [7:0] x_out;
    output [6:0] y_out;
    output [2:0] colour_out;
    reg[7:0] x_inside; 
    reg[6:0] y_inside;
    reg[2:0] colour_inside;
	 //wire[7:0] x_out;

    //Register for x, y, colour
    always @(posedge clock)
    begin
        if (!reset_n)
        begin
            x_inside <= 8'b00000000;
            y_inside <= 7'b0000000;
            colour_inside <= 3'b000;
        end
        else
        begin
            if (enable_x) begin
	             x_inside <= {1'b0,x_or_y};
					 end
            if (enable_y) begin
                y_inside <= x_or_y;
					 end
            if (enable_colour) begin
                colour_inside <= colour;
					 end
				if (enable_erase == 1'b1)
	         begin
		          colour_inside <= 3'b000;	 		 
 	         end
			   
        end
    end
    reg[1:0] x_count;
    reg[1:0] y_count;

    //Counter for x keeping the y coordinate the same.
    always @(posedge clock)
    begin
        if(!reset_n)
        begin
            x_count <= 2'b000;
		  end
 	     else if (enable == 1'b1)
	     begin
	         if (x_count == 2'b11) begin
					x_count <= 2'b00;
					end
				else
				begin
					x_count <= x_count + 1'b1;
					
				end
			end
	 end
    //Now fixing x, we add all the y pixels.

    wire y_enable;
    assign y_enable = (x_count == 2'b11) ? 1'b1: 1'b0;

    //Counter for y
    always @(posedge clock)
    begin
        if(!reset_n)
        begin
            y_count <= 2'b000;
		  end
		  else if (y_enable == 1'b1 && enable == 1'b1)
		  begin
		      if (y_count == 2'b11) begin
  		          y_count <= 2'b00;
	         end
	         else
	         begin
		          y_count <= y_count + 1'b1;
					 
 	         end
	    end
    end
	 
	 
//	 wire rate_out;
//	 //ratedivider
//	 ratedivider r0(
//		.enable(),
//		.load(),
//		.clock(clock),
//		.reset_n(resetn),
//		.q(rate_out)
//	 
//	 );
//	 
	 
	 
	 
    assign colour_out = colour_inside;
    assign x_out = x_inside + x_count;
    assign y_out = y_inside + y_count;
endmodule


module ratedivider(enable, load, clock, reset_n, q);
	input enable, clock, reset_n;
	input [27:0] load;
	output reg [27:0] q;

	always @(posedge clock)
	begin
		if (reset_n == 1'b0) //reset
			q <= load;
		else if (enable == 1'b1)
			begin
				if (q == 0) //reset
					q <= load;
				else // keep subtracting
					q <= q - 1'b1;
			end
	end
endmodule



module control(clock, reset_n, go, enable, enable_x, enable_y, enable_colour,write_en, start);
	 input go, clock, reset_n, start;
	 output reg enable, enable_x, enable_y, enable_colour, write_en;
	 
	 reg [3:0] curr_state, next_state;
	 
	 localparam  LOAD_X        = 4'd0,
                LOAD_X_WAIT   = 4'd1,
                LOAD_Y        = 4'd2,
                LOAD_Y_WAIT   = 4'd3,
                DRAW          = 4'd4;
					 
	// Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (curr_state)
                LOAD_X: next_state = ~go ? LOAD_X_WAIT : LOAD_X; // Loop in current state until value is input
                LOAD_X_WAIT: next_state = ~go ? LOAD_Y : LOAD_X_WAIT; // Loop in current state until go signal goes low
                LOAD_Y: next_state = ~start ? LOAD_Y_WAIT : LOAD_Y; // Loop in current state until value is input
                LOAD_Y_WAIT: next_state = ~start ? DRAW : LOAD_Y_WAIT; // Loop in current state until go signal goes low
		DRAW: next_state = ~go ? LOAD_X : DRAW;
            default: next_state = LOAD_X;
        endcase
    end // state_table
	 
	 // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        enable_x = 1'b0;
		  enable_y = 1'b0;
		  enable_colour = 1'b0;
		  enable = 1'b0;
		  write_en = 1'b0;

        case (curr_state)
            LOAD_X: begin
                enable_x <= 1'b1;
					 enable <= 1;
                end
				LOAD_X_WAIT: begin
					 enable <= 1;
                end
            LOAD_Y: begin
                enable_y <= 1'b1;
					 enable <= 1;
                end
				LOAD_Y_WAIT: begin
					 enable <= 1;
					 enable_colour <= 1'b1;
                end
            DRAW: begin
	       	        write_en <= 1'b1;
						  enable <= 1'b1;
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
	 
	 // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(!reset_n)
            curr_state <= LOAD_X;
        else
            curr_state <= next_state;
    end // state_FFS
endmodule

module combination(input clock, input reset_n, input go,
	 output[7:0] x_out, output[6:0] y_out, output[2:0] colour_out, 
	 input[6:0] x_or_y, input colour, input start);

    	 wire enable_x, enable_y, enable_colour, writeEn, enable;
         
  	 // Instansiate datapath
	datapath d0(.clock(clock), .reset_n(reset_n), 
		.x_or_y(x_or_y), .colour(colour), 
		.enable_x(enable_x), .enable_y(enable_y), 
		.enable_colour(enable_colour), .x_out(x_out),
		.y_out(y_out), .colour_out(colour_out), .enable(enable)
	);
    // Instansiate FSM control
	control c0(.clock(clock), .reset_n(reset_n), .go(go), 
		.enable(enable), .enable_x(enable_x),
       		.enable_y(enable_y), .enable_colour(enable_colour),
		.write_en(writeEn), .start(start)
	);
    
endmodule


// Part 2 skeleton

//module part2
//	(
//		CLOCK_50,						//	On Board 50 MHz
//		// Your inputs and outputs here
//        KEY,
//        SW,
//		// The ports below are for the VGA output.  Do not change.
//		VGA_CLK,   						//	VGA Clock
//		VGA_HS,							//	VGA H_SYNC
//		VGA_VS,							//	VGA V_SYNC
//		VGA_BLANK_N,						//	VGA BLANK
//		VGA_SYNC_N,						//	VGA SYNC
//		VGA_R,   						//	VGA Red[9:0]
//		VGA_G,	 						//	VGA Green[9:0]
//		VGA_B   						//	VGA Blue[9:0]
//	);
//
//	input			CLOCK_50;				//	50 MHz
//	input   [9:0]   SW;
//	input   [3:0]   KEY;
//
//	// Declare your inputs and outputs here
//	// Do not change the following outputs
//	output			VGA_CLK;   				//	VGA Clock
//	output			VGA_HS;					//	VGA H_SYNC
//	output			VGA_VS;					//	VGA V_SYNC
//	output			VGA_BLANK_N;				//	VGA BLANK
//	output			VGA_SYNC_N;				//	VGA SYNC
//	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
//	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
//	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
//
//	wire resetn;
//	assign resetn = KEY[0];
//
//	// Create the colour, x, y and writeEn wires that are inputs to the controller.
//	wire [2:0] colour;
//	wire [7:0] x;
//	wire [6:0] y;
//	wire writeEn;
//
//	// Create an Instance of a VGA controller - there can be only one!
//	// Define the number of colours as well as the initial background
//	// image file (.MIF) for the controller.
//	vga_adapter VGA(
//			.resetn(resetn),
//			.clock(CLOCK_50),
//			.colour(colour),
//			.x(x),
//			.y(y),
//			.plot(writeEn),
//			/* Signals for the DAC to drive the monitor. */
//			.VGA_R(VGA_R),
//			.VGA_G(VGA_G),
//			.VGA_B(VGA_B),
//			.VGA_HS(VGA_HS),
//			.VGA_VS(VGA_VS),
//			.VGA_BLANK(VGA_BLANK_N),
//			.VGA_SYNC(VGA_SYNC_N),
//			.VGA_CLK(VGA_CLK));
//		defparam VGA.RESOLUTION = "160x120";
//		defparam VGA.MONOCHROME = "FALSE";
//		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
//		defparam VGA.BACKGROUND_IMAGE = "black.mif";
//
//	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
//	// for the VGA controller, in addition to any other functionality your design may require.
//
//	wire ld_x, ld_y;
//
//    // Instansiate datapath
//	// datapath d0(...);
//
//	datapath d0(.clk(CLOCK_50),
//		.resetn(resetn),
//		.writeEn(writeEn),
//		.data_in(SW[6:0]),
//		.colour_in(SW[9:7]),
//		.x_out(x),
//		.y_out(y),
//		.colour_out(colour));
//
//    // Instansiate FSM control
//    // control c0(...);
//
//
//control c0(
//     .clk(CLOCK_50),
//     .resetn(resetn),
//     .go(~KEY[3]),
//     .ld_x(ld_x),
//     .ld_y(ld_y),
//     .ld_draw(writeEn)
//    );
//
//endmodule
//
//
//module datapath(
//    input clk,
//    input resetn,
//    input writeEn,
//    input ld_x,
//    input ld_y,
//    input [6:0] data_in,
//    input [2:0] colour_in,
//    output [7:0] x_out,
//    output [6:0] y_out,
//    output [2:0] colour_out
//    );
//
//    reg [7:0] x;
//    reg [6:0] y;
//
//    reg incrementX;
//    reg incrementY;
//
//    reg [1:0] x_count;
//    reg [1:0] y_count;
//
//	//input
//    // Registers x and y with respective load values
//    always @ (posedge clk) begin
//        if (!resetn) begin
//            x <= 8'd0;
//            y <= 8'd0;
//        end
//        else begin
//            if (ld_x)
//                x <= {1'b0, data_in};
//            if (ld_y)
//                y <= data_in;
//        end
//    end
//
//    //counter
//    always @ (posedge clk) begin
//        if (!resetn) begin
//	  incrementX <= 1'b1;
//	  incrementY <= 1'b0;
//          x_count <= 2'b00;
//	  y_count <= 2'b00;
//        end
//        else begin
//	  if (writeEn) begin
//	   if (y_count == 2'b11) begin
//	      y_count <= 2'b00;
//	      x_count <= 2'b00;
//           end
//
//	   if (x_count == 2'b11) begin
//	       x_count <= 2'b00;
//	       y_count <= y_count + 1;
//	   end
//
//	   if (x_count != 2'b11) begin
//	       x_count <= x_count + 1;
//	   end
//
//	  end
//	end
//    end
//
//    assign x_out = x + x_count;
//    assign y_out = y + y_count;
//    assign colour_out = colour_in;
//
//endmodule
//
//module control(
//    input clk,
//    input resetn,
//    input go,
//
//    output reg  ld_x, ld_y, ld_draw
//    );
//
//    reg [3:0] current_state, next_state;
//
//    localparam  S_LOAD_X        = 4'd0,
//                S_LOAD_X_WAIT   = 4'd1,
//                S_LOAD_Y        = 4'd2,
//                S_LOAD_Y_WAIT   = 4'd3,
//                S_LOAD_DRAW     = 4'd4;
//
//    // Next state logic aka our state table
//    always@(*)
//    begin: state_table
//            case (current_state)
//                S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X;
//                S_LOAD_X_WAIT: next_state = go ? S_LOAD_Y: S_LOAD_X_WAIT;
//                S_LOAD_Y: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y;
//                S_LOAD_Y_WAIT: next_state = go ? S_LOAD_DRAW : S_LOAD_Y_WAIT;
//                S_LOAD_DRAW: next_state = S_LOAD_X;
//            default:     next_state = S_LOAD_X;
//        endcase
//    end // state_table
//
//
//    // Output logic aka all of our datapath control signals
//    always @(*)
//    begin: enable_signals
//        // By default make all our signals 0
//        ld_x = 1'b0;
//        ld_y = 1'b0;
//		  ld_draw = 1'b0;
//
//        case (current_state)
//            S_LOAD_X: begin
//                ld_x = 1'b1;
//                end
//            S_LOAD_Y: begin
//                ld_y = 1'b1;
//                end
//            S_LOAD_DRAW: begin // Do A <- A * A
//                ld_draw = 1'b1;
//            end
//        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
//        endcase
//    end // enable_signals
//
//    // current_state registers
//    always@(posedge clk)
//    begin: state_FFs
//        if(!resetn)
//            current_state <= S_LOAD_X;
//        else
//            current_state <= next_state;
//    end // state_FFS
//endmodule

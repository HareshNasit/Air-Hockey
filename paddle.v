// Part 2 skeleton

module paddle(clock, reset_n, x_out, y_out, colour_out, enable_up, enable_down, enable_left, enable_right, writeEn);

	input clock, reset_n;
	input enable_up, enable_down, enable_left, enable_right;
	
	output [10:0] x_out, y_out;
	output [2:0] colour_out;
	output writeEn;
	
	wire [10:0] x_pos, y_pos;
	wire enable, enable_fcounter, y_count_done, enable_update, next_box, clear_sig;
	
	wire [2:0] colour;

	movement m0(
		.clock(clock), .reset_n(reset_n), 
		.enable_update(enable_update), 
		.x_pos_in(20), .y_pos_in(80), 
		.x_pos_out(x_pos), .y_pos_out(y_pos),
		.enable_up(enable_up), .enable_down(enable_down), 
		.enable_left(enable_left), .enable_right(enable_right));
	
	drawable p0(
		.clock(clock), .reset_n(reset_n), .enable(enable),
		.width(4), .height(20),
		.x_pos(x_pos), .y_pos(y_pos),
		.x_out(x_out), .y_out(y_out), 
		.colour(colour), .colour_out(colour_out), 
		.enable_fcounter(enable_fcounter),
		.y_count_done(y_count_done));
			
	control_paddle conp(
		.clock(clock), .reset_n(reset_n), 
		.write_en(writeEn), .enable(enable), 
		.colour(colour), .enable_update(enable_update), 
		.enable_fcounter(enable_fcounter), .next_box(next_box), 
		.y_count_done(y_count_done), .clear_sig(clear_sig));
		
	frame_counter f1(
		.clock(clock), .enable(enable_fcounter), 
		.resetn(reset_n), .signal_out(next_box), 
		.clear_sig(clear_sig));

endmodule

module movement(clock, enable_update, reset_n, enable_up, enable_down, enable_left, enable_right, x_pos_in, y_pos_in, x_pos_out, y_pos_out);
	input clock, reset_n, enable_update;
	input enable_up, enable_down, enable_left, enable_right;
	
	input [10:0] x_pos_in, y_pos_in;
	output [10:0] x_pos_out, y_pos_out;
	
	reg [10:0] x_pos, y_pos;
	
	always @(posedge clock)
	begin
		if (reset_n) begin
			x_pos <= x_pos_in;
			y_pos <= y_pos_in;
		end
		if (enable_update)begin
			if (enable_up) begin
				y_pos <= y_pos - 1;
			end
			
			if (enable_down) begin
				y_pos <= y_pos + 1;
			end
			
			if (enable_right) begin
				x_pos <= x_pos + 1;
			end
			
			if (enable_left) begin
				x_pos <= x_pos - 1;
			end
		end
	end
	
	assign x_pos_out = x_pos;
	assign y_pos_out = y_pos;

endmodule


module control_paddle( colour, clock, reset_n, write_en, enable, enable_erase, enable_update, enable_fcounter, next_box, y_count_done, clear_sig);
	 input clock, reset_n, next_box, y_count_done;
	 output reg enable, write_en, enable_erase, enable_update, enable_fcounter, clear_sig;
	 output reg [2:0] colour;
	 
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
		  colour <= 3'b000;
		  
        case (curr_state)
            DRAW: begin
					 enable <= 1;
					 write_en <= 1;
					 colour <= 3'b101;
					 
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

module drawable(clock, enable, reset_n, height, width, x_pos, y_pos, colour, x_out, y_out, colour_out, enable_fcounter, y_count_done);
	input clock, reset_n, enable, enable_fcounter;
	input [10:0]  width;
	input [10:0]  height;
	input [10:0]  x_pos;
	input [10:0]  y_pos;
	
	output reg y_count_done;
	
	input [2:0] colour;
	output [2:0] colour_out;

	 reg[10:0] x_count;
	 reg[10:0] y_count;
	 output [10:0] x_out;
	 output [10:0] y_out;
	 wire[10:0] x_inside; 
    wire[10:0] y_inside;
	 
	 assign x_inside = x_pos;
    assign y_inside = y_pos;
//assign colour_inside = colour;
	 

    wire y_enable;
    assign y_enable = (x_count == width) ? 1'b1: 1'b0;
	 
    //Counter for x keeping the y coordinate the same.
    always @(posedge clock)
    begin
        if(reset_n)
        begin
//				x_inside <= x_pos;
//            y_inside <= y_pos;
//            colour_inside <= colour;
				
            x_count <= 0;
				y_count <= 0;
		  end
 	     if (enable == 1'b1)
	     begin
				
				if (y_enable == 1'b1) begin
					 
					 if (y_count == height) begin
							y_count_done <= 1'b1;
							y_count <= 0;
					 end
				    else
					  begin
							y_count <= y_count + 1'b1;
							y_count_done <= 0;
					 end
				end
		  
	         if (x_count == width) begin
					x_count <= 0;
					end
				else
				begin
					x_count <= x_count + 1'b1;
					y_count_done <= 0;
				end
			end
			
			if(y_count_done == 1 || enable_fcounter) begin
				x_count <= 0;
				y_count <= 0;																																														
			end
	 end
    //Now fixing x, we add all the y pixels.
	 
    assign colour_out = colour;
    assign x_out = x_inside + x_count;
    assign y_out = y_inside + y_count;
	 
endmodule

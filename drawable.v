module drawable(clock, enable, reset_n, height, width, x_pos, y_pos, colour, x_out, y_out, colour_out, enable_fcounter, y_count_done);
	input clock, reset_n, enable, enable_fcounter;
	input [7:0] width;
	input [6:0] height;
	input [7:0] x_pos;
	input [6:0] y_pos;
	
	output reg y_count_done;
	
	input [2:0] colour;
	output [2:0] colour_out;
	reg[2:0] colour_inside;

	 reg[7:0] x_count;
	 reg[6:0] y_count;
	 output [7:0] x_out;
	 output [6:0] y_out;
	 reg[7:0] x_inside	; 
    reg[6:0] y_inside;
	 

    wire y_enable;
    assign y_enable = (x_count == width) ? 1'b1: 1'b0;
	 
    //Counter for x keeping the y coordinate the same.
    always @(posedge clock)
    begin
        if(reset_n)
        begin
				x_inside <= x_pos;
            y_inside <= y_pos;
            colour_inside <= colour;
				
            x_count <= 0;
				y_count <= 0;
		  end
 	     else if (enable == 1'b1)
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
	 
    assign colour_out = colour_inside;
    assign x_out = x_inside + x_count;
    assign y_out = y_inside + y_count;
	 
endmodule

module boundaries(clock, enable, reset_n, x_out, y_out, colour_out, done);
	input clock, enable, reset_n;
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] colour_out;
	
	wire [7:0] width;
	wire [6:0] height;
	wire [7:0] x_pos;
	wire [6:0] y_pos;
	
	wire draw_done;
	
	drawable top(
	.clock(clock), .enable(enable), .reset_n(reset_n), 
	.height(7'd4), .width(8'd50), 
	.x_pos(8'd0), .y_pos(7'd0), .colour(3'b010), 
	.x_out(x_out), .y_out(y_out), .colour_out(colour_out), 
	.enable_fcounter(enable_fcounter), .y_count_done(draw_done));
	
	control_boundaries adam_pussy(.clock(clock), .reset_n(reset_n), .width(width), .height(height), .x_pos(x_pos), .y_pos(y_pos), .draw_done(draw_done))

endmodule

module control_boundaries(clock, reset_n, width, height, x_pos, y_pos, draw_done);
	 input clock, reset_n,;
	 output reg [7:0] width;
	 output reg [6:0] height;
	 output reg [7:0] x_pos;
	 output reg [6:0] y_pos;
	 output enable_drawable;
	 
	 input reg draw_done;
	 
	 reg [3:0] curr_state, next_state;
	 
	 localparam  TOP        = 4'd0,
                BOTTOM   = 4'd1,
                TOP_LEFT        = 4'd2,
                BOTTOM_LEFT   = 4'd3,
					 TOP_RIGHT = 4'd4;
					 BOTTOM_RIGHT = 4'd5;
					 
	// Next state logic aka our stRESET_COUNTERate table
	
	//CONSIDER WAITING STATES
    always@(*)
    begin: state_table y_count_done
            case (curr_state)
                TOP: next_state = (draw_done == 1) ? BOTTOM: TOP; 
                BOTTOM: next_state = (draw_done == 1) ? TOP_LEFT : BOTTOM;
                TOP_LEFT: next_state  = (draw_done == 1) ? BOTTOM_LEFT: TOP_LEFT;
                BOTTOM_LEFT: next_state = (draw_done == 1) ? TOP_RIGHT: BOTTOM_LEFT;
					 TOP_RIGHT = next_state = (draw_done == 1) ? BOTTOM_RIGHT : TOP_RIGHT;
            default: next_state = TOP;
        endcase
    end // state_table
	 
	 // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signalsmodule 
        // By default make all our signals 0
		  width <= 0;
		  height <= 0;
		  x_pos <= 0;
		  y_pos <= 0;
		
        case (curr_state)
            TOP: begin
						width <= 100;
						height <= 5;
						x_pos <= 0;
						y_pos <= 0;
                end
				BOTTOM: begin
					   width <= 100;
						height <= 5;
						x_pos <= 0;
						y_pos <= 100;
                end
            TOP_LEFT: begin
                  width <= 5;
						height <= 12;
						x_pos <= 0;
						y_pos <= 0;
                end
				BOTTOM_LEFT: begin
				      width <= 5;
						height <= 12;
						x_pos <= 0;
						y_pos <= 100;
                end
				TOP_RIGHT: begin
					   width <= 5;
						height <= 12;
						x_pos <= 100;
						y_pos <= 0;
                end
				BOTTOM_RIGHT: begin
					   width <= 5;
						height <= 12;
						x_pos <= 100;
						y_pos <= 100;
                end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
	 
	 // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(reset_n)
            curr_state <= TOP;
        else
            curr_state <= next_state;
    end // state_FFS
endmodule


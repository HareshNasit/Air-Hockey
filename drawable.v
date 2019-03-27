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

module boundaries(signal_go, clock,reset_n, x_out, y_out, colour_out, writeEn);
	input clock, reset_n, signal_go;
	wire enable;
	output [10:0] x_out;
	output [10:0] y_out;
	output [2:0] colour_out;
	output writeEn;
	
	wire [10:0] width;
	wire [10:0] height;
	wire [10:0] x_pos;
	wire [10:0] y_pos;
	wire [2:0] colour;
	
	wire draw_done;
	wire enable_fcounter;
	wire reset_draw;
	
	control_boundaries cb0(.colour(colour), .signal_go(signal_go), .reset_draw(reset_draw), .clock(clock), .reset_n(reset_n), .width(width), .height(height), .x_pos(x_pos), .y_pos(y_pos), .draw_done(draw_done), .enable(enable), .writeEn(writeEn));
	
	drawable top(
	.clock(clock), .enable(enable), .reset_n(reset_draw), 
	.height(height), .width(width), 
	.x_pos(x_pos), .y_pos(y_pos), .colour(colour),
	.x_out(x_out), .y_out(y_out), .colour_out(colour_out), 
	.enable_fcounter(enable_fcounter), .y_count_done(draw_done));
	
	

endmodule

module control_boundaries(colour, signal_go, reset_draw, clock, reset_n, width, height, x_pos, y_pos, draw_done, enable, writeEn);
	 input clock, reset_n, signal_go;
	 output reg enable, writeEn, reset_draw;
	 output reg [10:0] width;
	 output reg [10:0] height;
	 output reg [10:0] x_pos;
	 output reg [10:0] y_pos;
	 output reg [2:0] colour;
	 input draw_done;
	 
	 reg [3:0] curr_state, next_state;
	 
	 localparam  TOP        = 4'd0,
                BOTTOM   = 4'd1,
                TOP_LEFT        = 4'd2,
                BOTTOM_LEFT   = 4'd3,
					 TOP_RIGHT = 4'd4,
					 BOTTOM_RIGHT = 4'd5,
					 START = 4'd6;
					 
	// Next state logic aka our stRESET_COUNTERate table
	
	//CONSIDER WAITING STATES
    always@(*)
    begin: state_table
            case (curr_state)
					 START: next_state = (signal_go == 1) ? TOP : START;
                TOP: next_state = (draw_done == 1) ? BOTTOM: TOP; 
                BOTTOM: next_state = (draw_done == 1) ? TOP_LEFT : BOTTOM;
                TOP_LEFT: next_state  = (draw_done == 1) ? BOTTOM_LEFT: TOP_LEFT;
                BOTTOM_LEFT: next_state = (draw_done == 1) ? TOP_RIGHT: BOTTOM_LEFT;
					 TOP_RIGHT: next_state = (draw_done == 1) ? BOTTOM_RIGHT : TOP_RIGHT;
					 BOTTOM_RIGHT: next_state = BOTTOM_RIGHT;
            default: next_state = START;
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
		  enable <= 0;
		  writeEn <= 0;
		  reset_draw <= 0;
		  colour <= 3'b111;
		  
        case (curr_state)
				START:
					reset_draw <= 1;
		  
            TOP: begin
						width <= 320;
						height <= 4;
						x_pos <= 8;
						y_pos <= 0;
						enable <= 1'b1;
						 writeEn <= 1;
						 colour <= 3'b010;
                end
				BOTTOM: begin
					   width <= 320;
						height <= 4;
						x_pos <= 8;
						y_pos <= 236;
						enable <= 1'b1;
						 writeEn <= 1;
						 colour <= 3'b010;


                end
            TOP_LEFT: begin
                  width <= 4;
						height <= 100;
						x_pos <= 8;
						y_pos <= 2;
						enable <= 1'b1;
						 writeEn <= 1;
						 colour <= 3'b010;

                end
				BOTTOM_LEFT: begin
				      width <= 4;
						height <= 100;
						x_pos <= 8;
						y_pos <= 122;
						enable <= 1'b1;
						 writeEn <= 1;
						 colour <= 3'b010;

                end
				TOP_RIGHT: begin
					   width <= 4;
						height <= 100;
						x_pos <= 306;
						y_pos <= 4;
						enable <= 1'b1;
						 writeEn <= 1;
						 colour <= 3'b010;

                end
				BOTTOM_RIGHT: begin
					   width <= 4;
						height <= 100;
						x_pos <= 306;
						y_pos <= 120;
						enable <= 1'b1;
						 writeEn <= 1;
						 colour <= 3'b010;

                end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
	 // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(reset_n)
            curr_state <= START;
        else
            curr_state <= next_state;
    end // state_FFS
endmodule


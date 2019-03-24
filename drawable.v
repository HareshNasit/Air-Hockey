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
	 reg[7:0] x_inside; 
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

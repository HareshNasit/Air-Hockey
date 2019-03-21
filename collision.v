

module collision(clock, enable, x, y, flip_vertical, flip_horizontal);
	//x_in, y_in is top left pixel of the box
	
	input clock, enable;
	
	input [7:0] x; 
   input [6:0] y;
	
	output reg flip_vertical, flip_horizontal;

	always @(posedge clock)
	begin
		if (enable) begin
		
			if (x == 7'b0000000) begin
				flip_horizontal <= ~flip_horizontal;
			end
			
			if (y == 6'b000000) begin
				flip_vertical <= ~flip_vertical;
			end
			
			if (x + 4 == 320) begin
				flip_horizontal <= ~flip_horizontal;
			end
		
			if (y + 4 == 240) begin
				flip_vertical <= ~flip_vertical;
			end
		
		end
	end


endmodule

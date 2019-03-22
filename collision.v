

module collision(clock, enable, reset_n, x, y, vertical, horizontal);
	//x_in, y_in is top left pixel of the box
	
	input clock, enable, reset_n;
	
	input [7:0] x; 
   input [6:0] y;
	
	output reg vertical, horizontal;

	always @(posedge clock)
	begin
		if (reset_n)begin
			horizontal <= 0;
			vertical <= 1;
		end
		else if (enable) begin
		
			if (x == 7'b0000000) begin
				horizontal <= 1;
			end 
			else if (x + 4 == 100) begin
				horizontal <= 0;
			end	
			
		  if (y == 6'b000000) begin
				vertical <= 0;
			end
			else if (y + 4 == 100) begin
				vertical <= 1;
			end
		
		
		end
	end


endmodule

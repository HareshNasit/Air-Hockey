

module collision(clock, enable, reset_n, x_ball, y_ball, x_paddle1, y_paddle1, x_paddle2, y_paddle2, vertical, horizontal, stop);
	//x_in, y_in is top left pixel of the box
	
	input clock, enable, reset_n;
	output reg stop;
	input [10:0] x_ball; 
   input [10:0] y_ball;
	input [10:0] x_paddle1, x_paddle2;
	input [10:0] y_paddle1, y_paddle2;
	
	output  vertical, horizontal;
	reg vertical_inside, horizontal_inside;

	always @(posedge clock)
	begin
		if (reset_n)begin
			horizontal_inside <= 0;
			vertical_inside <= 1;
		end
		else if (enable) begin
		
			if (x_ball == 7'b0000000) begin
				horizontal_inside <= 1;
			end 
			else if (x_ball + 4 == 320) begin
				horizontal_inside <= 0;
			end	
			
		  if (y_ball == 6'b000000) begin
				vertical_inside <= 0;
			end
			else if (y_ball + 4 == 240) begin
				vertical_inside <= 1;
			end
			
			if (x_ball == 0 && y_ball >= 150 && x_ball <= 320)
			begin
				stop <= 1;
			end
			else
			begin
				stop <= 0;
			end
		end
//		if (x_paddle1 <= x_ball && x_ball <= (x_paddle1 + 4)) 
//		begin
//			if (y_paddle1 <= y_ball && y_ball <= (y_paddle1 + 40))
//			begin
//				vertical_inside <= ~vertical_inside;
//				horizontal_inside <= ~horizontal_inside;
//			end
//		end
//		if (x_paddle2 <= x_ball && x_ball <= (x_paddle2 + 4)) 
//		begin
//			if (y_paddle2 <= y_ball && y_ball <= (y_paddle2 + 40))
//			begin
//				vertical_inside <= ~vertical_inside;
//				horizontal_inside <= ~horizontal_inside;
//			end
//		end
//		
	end

	assign vertical = vertical_inside;
	assign horizontal = horizontal_inside;

endmodule

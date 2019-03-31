module score(clock, reset_n, enable_increment, score_out);
	input clock, reset_n, enable_increment;
	output reg[2:0] score_out;
	
	always @(posedge clock)
	begin
		if (enable_increment)
		begin
			score_out <= score_out + 1'b1;
		end
		if (score_out == 3'b111)
		begin
			score_out = 3'b000;
		end
	end
endmodule

module timer(clock, enable_timer, reset_n, time_out, clear_sig	);
	input clock, reset_n, enable, clear_sig;
	output[27:0] time_out;
	wire[27:0] rate_out;
	wire enable_counter;
	 //ratedivider CHANGE THE FREQEUENCY LOAD
	 ratedivider r1(
		.enable(enable_timer),
		.load(50000000), 
		.clock(clock),
		.reset_n(reset_n),
		.q(rate_out),
		.clear_sig(clear_sig)
	 );
	 
	 assign enable_counter = (rate_out == 0) ? 1'b1 : 1'b0;
	 
	 ratedivider r2(
		.enable(enable_counter),
		.load(150), 
		.clock(clock),
		.reset_n(reset_n),
		.q(time_out),
		.clear_sig(clear_sig)
	 );
	 
	 
endmodule


module frame_counter(clock, resetn,signal_out, enable);
	input clock, resetn, enable;
	output signal_out;
	wire[27:0] rate_out;
	 //ratedivider CHANGE THE FREQEUENCY LOAD
	 ratedivider r1(
		.enable(enable),
		.load(10), 
		.clock(clock),
		.reset_n(resetn),
		.q(rate_out)
	 );
	 wire enable_frame;
	 wire[27:0] output_frame;
	 assign enable_frame = (rate_out == 0) ? 1 : 0;
	 //ratedivider CHANGE THE FREQEUENCY LOAD
	 ratedivider r2(
		.enable(enable_frame),
		.load(15), 
		.clock(clock),
		.reset_n(resetn),
		.q(output_frame)
	 );
	 
	 assign signal_out = (output_frame == 0) ? 1 : 0;
endmodule

module ratedivider(enable, load, clock, reset_n, q);
	input enable, clock, reset_n;
	input [27:0] load;
	output reg [27:0] q;

	always @(posedge clock)
	begin
		if (reset_n == 1'b1) //reset
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

module frame_counter(clear_sig, clock, resetn, signal_out, enable);
	input clock, resetn, enable, clear_sig;
	output signal_out;
	wire[27:0] rate_out;
	 wire enable_frame;
	 wire[27:0] output_frame;
	 //ratedivider CHANGE THE FREQEUENCY LOAD
	 ratedivider r1(
		.enable(enable),
		.load(10), 
		.clock(clock),
		.reset_n(resetn ),
		.q(rate_out),
		.clear_sig(clear_sig)
	 );
	
	 assign enable_frame = (rate_out == 0) ? 1 : 0;
	 //ratedivider CHANGE THE FREQEUENCY LOAD
	 ratedivider r2(
		.enable(enable_frame),
		.load(15), 
		.clock(clock),
		.reset_n(resetn ),
		.q(output_frame),
		.clear_sig(clear_sig)
	 );
	 
	 assign signal_out = (output_frame == 0) ? 1 : 0;
endmodule

module ratedivider(enable, load, clock, reset_n, q, clear_sig);
	input enable, clock, reset_n, clear_sig;
	input [27:0] load;
	output reg [27:0] q;

	always @(posedge clock)
	begin
		if (reset_n == 1'b1 || clear_sig == 1'b1) //reset
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

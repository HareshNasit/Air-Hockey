// Part 2 skeleton

module milestone2_ball
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		  HEX0,
		  HEX3,
		  HEX2,
		  HEX4,
		  LEDR,
	 PS2_CLK,
	 PS2_DAT,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	inout PS2_CLK;
	inout PS2_DAT;
	
	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output [6:0] HEX0;
	output [6:0] HEX4;
	
	output [6:0] HEX3;
	output [6:0] HEX2;
	
	output  [9:0] LEDR;


	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn; //VGA reset low
	assign resetn = SW[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [10:0] x;
	wire [10:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(~resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	wire clear_signal, enable, enable_erase, enable_update, enable_fcounter, next_box, y_count_done, next_boxx, game_end;
	wire [3:0] p1_curr_score, p2_curr_score;
	wire [9:0] control;
	wire [3:0] digit_1, digit_2;
	
	wire [3:0] time_1, time_2;


	
	 paddle_sim po(
	 .clock(CLOCK_50), .reset_n(resetn), .go(~KEY[0]),
	 .p1_up(control[1]), .p1_down(control[3]), .p1_left(control[2]), .p1_right(control[4]),
	 .p2_up(control[7]), .p2_down(control[8]), .p2_left(control[5]), .p2_right(control[6]),
	 .x(x), .y(y), .colour_out(colour), .writeEn(writeEn), 
	 .p1_curr_score(p1_curr_score), .p2_curr_score(p2_curr_score),
	 .timer_digit_1(time_1), .timer_digit_2(time_2), 
	// .p1_score(~KEY[2]), .p2_score(~KEY[1]),
	 .p1_scoret(LEDR[1]), .p2_scoret(LEDR[0]),
	 .game_end_out(game_end)
	 );
	 
	 hex_decoder h0(p2_curr_score/2, HEX0);
	 
	 hex_decoder h1(p1_curr_score/2, HEX4);
	 

	 hex_decoder h2(digit_1, HEX3);
	 
	 hex_decoder h3(digit_2, HEX2);
	 
	 assign LEDR[3] = game_end;
	 
	 comparator(
		.player_1_score(p1_curr_score), 
		.player_2_score(p2_curr_score), 
		.time_digit_1(time_1), 
		.time_digit_2(time_2),
		.digit_1(digit_1), .digit_2(digit_2), 
		.enable(game_end), 
		.clock(CLOCK_50));

	 
	 
	 keyboard_tracker #(.PULSE_OR_HOLD(0)) tester(
	     .clock(CLOCK_50),
		  .reset(~resetn),
		  .PS2_CLK(PS2_CLK),
		  .PS2_DAT(PS2_DAT),
		  .w(control[1]),
		  .a(control[2]),
		  .s(control[3]),
		  .d(control[4]),
		  .left(control[5]),
		  .right(control[6]),
		  .up(control[7]),
		  .down(control[8]),
		  .space(control[9]),
		  .enter(control[0])
		  );
	 
endmodule

module comparator(player_1_score, player_2_score, time_digit_1, time_digit_2, digit_1, digit_2, enable, clock);

	input clock, enable;
	input [3:0] player_1_score;
	input [3:0] player_2_score;
	
	input [3:0] time_digit_1;
	input [3:0] time_digit_2;
	
	output reg [6:0] digit_1;
	output reg [6:0] digit_2;


	always @(posedge clock)
	begin
		digit_1 <= time_digit_1;
		digit_2 <= time_digit_2;

	
		if (enable) begin
			if (player_1_score > player_2_score) begin
				digit_1 <= 4'hA;
				digit_2 <= 4'h1;
			end
			else if (player_1_score < player_2_score) begin
				digit_1 <= 4'hA;
				digit_2 <= 4'h2;
			end
			else begin
				digit_1 <= 4'hb;
				digit_2 <= 4'hb;
			end
		
		end
		
	end

endmodule


module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1100;
            4'hb: segments = 7'b100_0010;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule



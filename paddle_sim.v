module paddle_sim(
	 clock, reset_n, go,
	 p1_up, p1_down, p1_left, p1_right,
	 p2_up, p2_down, p2_left, p2_right,
	 x, y, colour_out, writeEn,
	 p1_curr_score, p2_curr_score,
	 timer_digit_2, timer_digit_1,
	 p1_scoret, p2_scoret, game_end_out
	 );
	 
	 input clock, reset_n, go;
	 input p1_up, p1_down, p1_left, p1_right;
	 input p2_up, p2_down, p2_left, p2_right;
	 
	// input p1_score, p2_score;
	 
	 wire p1_score, p2_score;
	 output p1_scoret, p2_scoret;
	 output game_end_out;
	 
	 
	 assign p1_scoret = p1_score;
	 assign p2_scoret = p2_score;


	 
	 output [3:0] p1_curr_score, p2_curr_score;
	 
	 output writeEn;
	 output [10:0] x, y;
	 output [2:0] colour_out;
	 output [3:0] timer_digit_1, timer_digit_2;
	 
	 wire p1_enDraw, p2_enDraw, ball_enDraw, bounds_enDraw, clear_enDraw;
	 wire p1_finYcount, p2_finYcount, ball_finYcount, bounds_finYcount, clear_finYcount;
	 wire	enable_framecounter, erase_start, clear_framecounter, enable_update, reset_fsm;
	 wire enable_timer, game_end;
		
	 wire [10:0] p1_x, p1_y;
	 wire [10:0] p2_x, p2_y;
	 wire [10:0] ball_x, ball_y;
	 wire [10:0] bounds_x, bounds_y;
	 wire [10:0] clear_x, clear_y;

	 wire [10:0] ball_spawn_x, ball_spawn_y;
	 
	 
	 wire [2:0] colour_1, colour_2, colour_ball, colour_bounds, colour_clear;
	 wire [2:0] colour;
	 	 
	 score s1(.clock(clock), .reset_n(reset_n), .enable_increment(p2_score), .score_out(p1_curr_score));
	 
	 score s2(.clock(clock), .reset_n(reset_n), .enable_increment(p1_score), .score_out(p2_curr_score));
	 
	 xymux xy(
		.clock(clock),
		.p1_enDraw(p1_enDraw), .p2_enDraw(p2_enDraw), .ball_enDraw(ball_enDraw), .bounds_enDraw(bounds_enDraw), .clear_enDraw(clear_enDraw),
		.p1_x(p1_x), .p1_y(p1_y), .p1_colour(colour_1),
		.p2_x(p2_x), .p2_y(p2_y), .p2_colour(colour_2), 
		.ball_x(ball_x), .ball_y(ball_y), .ball_colour(colour_ball),
		.bounds_x(bounds_x), .bounds_y(bounds_y), .bounds_colour(colour_bounds),
		.clear_x(clear_x), .clear_y(clear_y), .clear_colour(colour_clear),
		.x(x), .y(y), .colour_out(colour_out)
	 );
	 
	 boundaries bounds(
		.signal_go(bounds_enDraw), .clock(clock), .reset_n(reset_fsm), 
		.x_out(bounds_x), .y_out(bounds_y), .colour_out(colour_bounds), 
		.complete_bounds(bounds_finYcount));
	 
	 drawable clear(.clock(clock), .reset_n(reset_fsm), .enable(clear_enDraw),
		.width(312), .height(232),
		.x_pos(4), .y_pos(4),
		.x_out(clear_x), .y_out(clear_y), 
		.colour(colour), .colour_out(colour_clear), 
		.enable_fcounter(enable_framecounter),
		.y_count_done(clear_finYcount));
	 
	 ball b0(
		.clock(clock), .reset_n(reset_fsm), 
		.x_in(ball_spawn_x), .y_in(ball_spawn_y), .colour_in(colour), 
		.p1_x(p1_x), .p1_y(p1_y), .p2_x(p2_x), .p2_y(p2_y), .p1_goal(p1_score), .p2_goal(p2_score),
		.x_out(ball_x), .y_out(ball_y), .colour_out(colour_ball), 
		.enable(ball_enDraw), .enable_fcounter(enable_framecounter), .enable_update(enable_update), .y_count_done(ball_finYcount));
	 
	 paddletest p1(
		.clock(clock), .reset_n(reset_fsm), .y_count_done(p1_finYcount), .enable(p1_enDraw),
		.x_in(30), .y_in(100), .colour_in(colour), .enable_fcounter(enable_framecounter),
		.x_out(p1_x), .y_out(p1_y), .colour_out(colour_1), .enable_update(enable_update),
		.enable_up(p1_up), .enable_down(p1_down), .enable_left(p1_left), .enable_right(p1_right));
		
	 paddletest p2(
		.clock(clock), .reset_n(reset_fsm), .y_count_done(p2_finYcount), .enable(p2_enDraw),
		.x_in(290), .y_in(100), .colour_in(colour), .enable_fcounter(enable_framecounter),
		.x_out(p2_x), .y_out(p2_y), .colour_out(colour_2), .enable_update(enable_update),
		.enable_up(p2_up), .enable_down(p2_down), .enable_left(p2_left), .enable_right(p2_right));
	 
	 paddle_animation pa(
		.clock(clock), .reset_n(reset_n || game_end), .reset_fsm(reset_fsm), .go(go),
		.p1_enDraw(p1_enDraw), .p2_enDraw(p2_enDraw), .ball_enDraw(ball_enDraw), .bounds_enDraw(bounds_enDraw), .clear_enDraw(clear_enDraw),
		.p1_finYcount(p1_finYcount), .p2_finYcount(p2_finYcount), .ball_finYcount(ball_finYcount), .bounds_finYcount(bounds_finYcount), .clear_finYcount(clear_finYcount),
		.enable_framecounter(enable_framecounter), .erase_start(erase_start), .clear_framecounter(clear_framecounter),
		.enable_update(enable_update), .writeEn(writeEn), .colour(colour),
		.ball_spawn_x(ball_spawn_x), .ball_spawn_y(ball_spawn_y),
		.p1_score(p1_score), .p2_score(p2_score),
		.enable_timer(enable_timer), .game_end_out(game_end_out)
		);
		 
	timer t0(
		.clock(clock), 
		.enable_timer(enable_timer), .game_end(game_end),
		.reset_n(reset_n),  
		.digit_1(timer_digit_1), .digit_2(timer_digit_2));
	 
	frame_counter f1(
		.clock(clock), .enable(enable_framecounter), 
		.resetn(reset_fsm), .signal_out(erase_start), 
		.clear_sig(clear_framecounter));
	 
endmodule

module timer(clock, enable_timer, reset_n, digit_1, digit_2, game_end);
	input clock, reset_n, enable_timer;

	wire[27:0] rate_out;
	wire decrement_2, decrement_1;
	
	output reg [3:0] digit_1;
	output reg [3:0] digit_2;
	output reg game_end;
	
	 //ratedivider CHANGE THE FREQEUENCY LOAD
	 ratedivider r1(
		.enable(enable_timer),
		.load(50000000), 
		.clock(clock),
		.reset_n(reset_n),
		.q(rate_out),
		.clear_sig(0)
	 );
	 
	  
	 assign decrement_2 = (rate_out == 0) ? 1'b1 : 1'b0;
	 	 
	always @(posedge clock)
	begin
		if (reset_n) begin
			digit_1 <= 9;
			digit_2 <= 0;
			game_end <= 0;
		end
		
		if (digit_1 <= 0 && digit_2 == 0) begin
			digit_2 <= 9;
			game_end <= 1;
		end
		
		if (decrement_2 && digit_2 == 0) begin
			digit_2 <= 9;
			digit_1 <= digit_1 - 1;
		end
		else if (decrement_2) begin
			digit_2 <= digit_2 - 1;
		end
	   
	end

endmodule


module score(clock, reset_n, enable_increment, score_out);
	input clock, reset_n, enable_increment;
	output reg [3:0] score_out;
	
	always @(posedge clock)
	begin
		if (reset_n ) begin
			score_out <= 0;
		end
		if (enable_increment)
		begin
			score_out <= score_out + 1'b1;
		end
	end
endmodule

module xymux(clock,
	p1_enDraw, p2_enDraw, ball_enDraw, bounds_enDraw, clear_enDraw,
	p1_x, p1_y, p1_colour,
	p2_x, p2_y, p2_colour,
	ball_x, ball_y, ball_colour,
	bounds_x, bounds_y, bounds_colour,
	clear_x, clear_y, clear_colour,
	x, y, colour_out);
	
	input clock;
	input p1_enDraw, p2_enDraw, ball_enDraw, bounds_enDraw, clear_enDraw;
	input [10:0] p1_x, p1_y;
	input [10:0] p2_x, p2_y;
	input [10:0] ball_x, ball_y;
	input [10:0] bounds_x, bounds_y;
	input [10:0] clear_x, clear_y;
	
	input [2:0] p1_colour, p2_colour, ball_colour, bounds_colour, clear_colour;
	
	output reg [10:0] x,y;
	output reg [2:0] colour_out;
	
	always@(posedge clock)
	begin
		if (p1_enDraw) begin
			x <= p1_x;
			y <= p1_y;
			colour_out <= p1_colour;
		end
		else if (p2_enDraw) begin
			x <= p2_x;
			y <= p2_y;
			colour_out <= p2_colour;
		end
		else if (ball_enDraw) begin
			x <= ball_x;
			y <= ball_y;
			colour_out <= ball_colour;
		end
		else if (bounds_enDraw) begin
			x <= bounds_x;
			y <= bounds_y;
			colour_out <= bounds_colour;
		end
		else if (clear_enDraw) begin
			x <= clear_x;
			y <= clear_y;
			colour_out <= clear_colour;
		end
	
	end
	
endmodule
 
module paddletest(clock, reset_n, x_in, y_in, colour_in, x_out, y_out, colour_out, enable_up, enable_down, enable_left, enable_right, enable, enable_fcounter, enable_update, y_count_done);

	input clock, reset_n, enable, enable_fcounter, enable_update;
	input enable_up, enable_down, enable_left, enable_right;
	
	input [10:0] x_in, y_in;
	input [2:0] colour_in;
	
	output [10:0] x_out, y_out;
	output [2:0] colour_out;
	output y_count_done;
	
	wire [10:0] x_pos, y_pos;
	
	wire [2:0] colour;

	movement m0(
		.clock(clock), .reset_n(reset_n), 
		.enable_update(enable_update), 
		.x_pos_in(x_in), .y_pos_in(y_in), 
		.x_pos_out(x_pos), .y_pos_out(y_pos),
		.enable_up(enable_up), .enable_down(enable_down), 
		.enable_left(enable_left), .enable_right(enable_right));
	
	drawable p0(
		.clock(clock), .reset_n(reset_n), .enable(enable),
		.width(4), .height(20),
		.x_pos(x_pos), .y_pos(y_pos),
		.x_out(x_out), .y_out(y_out), 
		.colour(colour_in), .colour_out(colour_out), 
		.enable_fcounter(enable_fcounter),
		.y_count_done(y_count_done));
			
//	control_paddle conp(
//		.clock(clock), .reset_n(reset_n), 
//		.write_en(writeEn), .enable(enable), 
//		.colour(colour), .enable_update(enable_update), 
//		.enable_fcounter(enable_fcounter), .next_box(next_box), 
//		.y_count_done(y_count_done), .clear_sig(clear_sig));
//		
//	frame_counter f1(
//		.clock(clock), .enable(enable_fcounter), 
//		.resetn(reset_n), .signal_out(next_box), 
//		.clear_sig(clear_sig));

endmodule

module movement(clock, enable_update, reset_n, enable_up, enable_down, enable_left, enable_right, x_pos_in, y_pos_in, x_pos_out, y_pos_out);
	input clock, reset_n, enable_update;
	input enable_up, enable_down, enable_left, enable_right;
	
	input [10:0] x_pos_in, y_pos_in;
	output [10:0] x_pos_out, y_pos_out;
	
	reg [10:0] x_pos, y_pos;
	
	always @(posedge clock)
	begin
		if (reset_n) begin
			x_pos <= x_pos_in;
			y_pos <= y_pos_in;
		end
		if (enable_update)begin
			if (enable_up && y_pos >= 6) begin
				y_pos <= y_pos - 1;
			end
			
			if (enable_down && y_pos <= 214) begin
				y_pos <= y_pos + 1;
			end
			
			if (enable_right && x_pos <= 310) begin
				x_pos <= x_pos + 1;
			end
			
			if (enable_left && x_pos >= 6) begin
				x_pos <= x_pos - 1;
			end
		end
	end
	
	assign x_pos_out = x_pos;
	assign y_pos_out = y_pos;

endmodule


 
module paddle_animation(clock, reset_n, colour, reset_fsm, go,
	p1_enDraw, p2_enDraw, ball_enDraw, bounds_enDraw, clear_enDraw,
	p1_finYcount, p2_finYcount, ball_finYcount, bounds_finYcount, clear_finYcount,
	enable_framecounter, erase_start, 
	clear_framecounter, writeEn, enable_update, game_end_out,
	ball_spawn_x, ball_spawn_y, p1_score, p2_score, enable_timer
	);
	
	input clock, reset_n, go;
	input p1_finYcount, p2_finYcount, ball_finYcount, bounds_finYcount, clear_finYcount;
	input p1_score, p2_score;
	
	output reg p1_enDraw, p2_enDraw, ball_enDraw, bounds_enDraw, clear_enDraw;
	output reg game_end_out;
	
	input erase_start;
	output reg enable_framecounter, clear_framecounter;
	output reg writeEn, enable_update, reset_fsm, enable_timer;
	
	output reg [2:0] colour;
	output reg [10:0] ball_spawn_x;
	output reg [10:0] ball_spawn_y;

	 reg [3:0] curr_state, next_state;
	 
	 localparam  START = 4'd0,
					 DRAWBOUNDS = 4'd1,
					 DRAWP1 = 4'd2,
					 DRAWP2 = 4'd3,
					 DRAWBALL = 4'd4 ,
                RESET_COUNTER = 4'd5,
                ERASEP1 = 4'd6,
					 ERASEP2 = 4'd7,
					 ERASEBALL = 4'd8,
                UPDATE = 4'd9,
					 CLEAR_SCREEN = 4'd10,
					 P1_GOAL = 4'd11,
					 P2_GOAL = 4'd12;
					 
					 
	// Next state logic aka our stRESET_COUNTERate table
    always@(*)
    begin: state_table 
            case (curr_state)
					 START:  next_state = (go == 1) ? DRAWBOUNDS: START; 
					 DRAWBOUNDS: next_state = (bounds_finYcount == 1) ? CLEAR_SCREEN: DRAWBOUNDS;
					 
					 P1_GOAL : next_state =  CLEAR_SCREEN;
					 P2_GOAL : next_state =  CLEAR_SCREEN;
					 
					 CLEAR_SCREEN : next_state = (clear_finYcount == 1)? DRAWP1: CLEAR_SCREEN;
					 			 
                DRAWP1: next_state = (p1_finYcount == 1) ? DRAWP2: DRAWP1; 
					 DRAWP2: next_state = (p2_finYcount == 1) ? DRAWBALL: DRAWP2; 
					 DRAWBALL: next_state = (ball_finYcount == 1) ? RESET_COUNTER: DRAWBALL;
					 
                RESET_COUNTER: next_state = (erase_start == 1) ? ERASEP1 : RESET_COUNTER;
					 
                ERASEP1: next_state  = (p1_finYcount == 1) ? ERASEP2: ERASEP1;
					 ERASEP2: next_state  = (p2_finYcount == 1) ? ERASEBALL: ERASEP2;
					 ERASEBALL: next_state = (ball_finYcount == 1) ? UPDATE: ERASEBALL;
					 
                UPDATE: next_state = DRAWP1;
					 
            default: next_state = START;
        endcase
    end // state_table
	 
	 // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signalsmodule 
        // By default make all our signals 0
		  p1_enDraw <= 0;  
		  p2_enDraw <= 0; 
		  ball_enDraw <= 0;
		  bounds_enDraw <= 0;
		  clear_enDraw <= 0;
		  writeEn <= 0;
		  
		  reset_fsm <= 0;
		  game_end_out <= 0;

		  
		  enable_framecounter<= 0;
		  clear_framecounter<= 0;
		  
		  colour <= 3'b000;
		  enable_update <= 0;
		  
        case (curr_state)
				START: begin
					 ball_spawn_x <= 160;
					 ball_spawn_y <= 120;
					 reset_fsm <= 1;
					 enable_timer <= 0;
					 game_end_out <= 1;

                end
					 
				P2_GOAL: begin
					 ball_spawn_x <= 44;
					 ball_spawn_y <= 110;
					 reset_fsm <= 1;
					 
                end
				P1_GOAL: begin
					 ball_spawn_x <= 264;
					 ball_spawn_y <= 110;
					 reset_fsm <= 1;
					 
                end
				
				CLEAR_SCREEN: begin
					 clear_enDraw <= 1;
					 writeEn <= 1;
					 colour <= 3'b000;
					 
                end
			   DRAWBOUNDS: begin
					 bounds_enDraw <= 1;
					 writeEn <= 1;
					 enable_timer <= 1;
					 //colour <= 3'b101;
                end
				CLEAR_SCREEN: begin
					 clear_enDraw <= 1;
					 writeEn <= 1;
					 colour <= 3'b000;
					 
                end
		  
            DRAWP1: begin
					 p1_enDraw <= 1;
					 writeEn <= 1;
					 colour <= 3'b101;
					 
                end
				DRAWP2: begin
					 p2_enDraw <= 1;
					 writeEn <= 1;
					 colour <= 3'b010;
					 
                end
				DRAWBALL: begin
					 ball_enDraw <= 1;
					 writeEn <= 1;
					 colour <= 3'b100;
                end
				RESET_COUNTER: begin
					 enable_framecounter <= 1;
                end
            ERASEP1: begin
                p1_enDraw <= 1;
					 writeEn <= 1;
					 clear_framecounter <= 1;
					 
                end
				ERASEP2: begin
                p2_enDraw <= 1;
					 writeEn <= 1;
					 
                end
				ERASEBALL: begin
                ball_enDraw <= 1;
					 writeEn <= 1;
                end
				UPDATE: begin
					 enable_update <= 1;
                end
				
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
	 
	 // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(reset_n) begin
            curr_state <= START;
				end
		  else if (p1_score) begin
				curr_state <= P1_GOAL;
				end
		  else if (p2_score) begin
		      curr_state <= P2_GOAL;
				end
        else begin
            curr_state <= next_state;
				end
    end // state_FFS
endmodule

module ball(clock, reset_n, x_in, y_in, colour_in, x_out, y_out, colour_out, enable, enable_fcounter, enable_update, y_count_done,
	p1_x, p1_y, p2_x, p2_y, p1_goal, p2_goal
);
   
	input clock, reset_n, enable, enable_fcounter, enable_update;
	input [10:0] p1_x, p1_y, p2_x, p2_y;
	
	input [10:0] x_in, y_in;
	input [2:0] colour_in;
	
	output [10:0] x_out, y_out;
	output [2:0] colour_out;
	output y_count_done;
	output p1_goal, p2_goal;
	
	wire [10:0] x_pos, y_pos;
	
	  
	collision2 col(
	 .enable(enable_update), .reset_n(reset_n), .clock(clock), 
	 .x_ball(x_in), .y_ball(y_in),
	 .x_ball_out(x_pos), .y_ball_out(y_pos),
	 .x_paddle1(p1_x), .y_paddle1(p1_y), .x_paddle2(p2_x), .y_paddle2(p2_y),
	 .p1_goal(p1_goal), .p2_goal(p2_goal)
	);
 
	 drawable p0(
		.clock(clock), .reset_n(reset_n), .enable(enable),
		.width(10), .height(10),
		.x_pos(x_pos), .y_pos(y_pos),
		.x_out(x_out), .y_out(y_out), 
		.colour(colour_in), .colour_out(colour_out), 
		.enable_fcounter(enable_fcounter),
		.y_count_done(y_count_done));
  
endmodule

module collision2(clock, enable, reset_n, x_ball, y_ball, x_paddle1, y_paddle1, x_paddle2, y_paddle2, x_ball_out, y_ball_out, p1_goal, p2_goal);
	//x_in, y_in is top left pixel of the box
	
	input clock, enable, reset_n;
	input [10:0] x_ball; 
   input [10:0] y_ball;
	input [10:0] x_paddle1, x_paddle2;
	input [10:0] y_paddle1, y_paddle2;
	
	reg [10:0] x_ball_inside; 
   reg [10:0] y_ball_inside;
	
	output [10:0] x_ball_out;
	output [10:0] y_ball_out;
	
	output reg p1_goal, p2_goal;
	
	reg horizontal;
	reg vertical;
	
	always @(posedge clock)
	begin
		if (reset_n) begin
			x_ball_inside <= x_ball;
			y_ball_inside <= y_ball;
			horizontal <= 1;
			vertical <= 1;
			p1_goal <= 1'b0;
			p2_goal <= 1'b0;
		end
		else if (enable) begin
		
			//walls
			if (x_ball_inside == 6) begin
				horizontal <= 1;
			end 
			else if (x_ball_inside  == 302) begin
				horizontal <= 0;
			end	
			
		  if (y_ball_inside == 6) begin
				vertical <= 0;
			end
			else if (y_ball_inside  == 220) begin
				vertical <= 1;
			end
		
		//Paddles

		//Paddle 1
		if ((x_ball_inside + 10) == x_paddle1)
		begin
			if (y_paddle1 <= y_ball_inside && y_ball_inside <= (y_paddle1 + 20))
			begin
				if (horizontal == 1)
				begin
					horizontal <= 0;
				end
				//vertical <= ~vertical;
			end
		end
		else if ((x_ball_inside) == (x_paddle1 + 4))
		begin
			if (y_paddle1 <= y_ball_inside && y_ball_inside <= (y_paddle1 + 20))
			begin
				if (horizontal == 0)
				begin
					horizontal <= 1;
				end
				//vertical <= ~vertical;
			end
		end
		
		//Paddle 2
		if ((x_ball_inside + 10) == (x_paddle2))
		begin
			if (y_paddle2 <= y_ball_inside && y_ball_inside <= (y_paddle2 + 20))
			begin
				if (horizontal == 1)
				begin
					horizontal <= 0;
				end
				//vertical <= ~vertical;
			end
		end
		else if ((x_ball_inside) == (x_paddle2 + 4))
		begin
			if (y_paddle2 <= y_ball_inside && y_ball_inside <= (y_paddle2 + 20))
			begin
				if (horizontal == 0)
				begin
					horizontal <= 1;
				end
				//vertical <= ~vertical;
			end
		end
		
		//Goal collision
		if (x_ball_inside == 6 && y_ball_inside >= 90 && y_ball_inside <= 150)
		begin
			p2_goal <= 1'b0;
			p1_goal <= 1'b1;
		end
		else if (x_ball_inside + 10 == 306 && y_ball_inside >= 90 && y_ball_inside <= 150)
		begin
			p1_goal <= 1'b0;
			p2_goal <= 1'b1;
		end
		else
		begin
			p1_goal <= 1'b0;
			p2_goal <= 1'b0;
		end
		//movement
			if (vertical == 1'b1) begin
						y_ball_inside <= y_ball_inside - 1'b1;
					 end
			 if (horizontal == 1'b1) begin
					x_ball_inside <= x_ball_inside + 1'b1;
			 end
			 if (vertical == 1'b0) begin
					y_ball_inside <= y_ball_inside + 1'b1;
			 end
			 if (horizontal == 1'b0) begin
					x_ball_inside <= x_ball_inside - 1'b1;
			 end
		
		end
		
		
	end
	
	assign x_ball_out = x_ball_inside;
	assign y_ball_out = y_ball_inside;

endmodule

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
				y_count_done <= 1'b0;
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


module boundaries(signal_go, clock,reset_n, x_out, y_out, colour_out, complete_bounds);
	
	input clock, reset_n, signal_go;
	output complete_bounds;
	
	wire enable;
	output [10:0] x_out;
	output [10:0] y_out;
	output [2:0] colour_out;
	
	wire [10:0] width;
	wire [10:0] height;
	wire [10:0] x_pos;
	wire [10:0] y_pos;
	wire [2:0] colour;
	
	wire draw_done;
	wire enable_fcounter;
	wire reset_draw;
	
	control_boundaries cb0(.colour(colour), .signal_go(signal_go), .reset_draw(reset_draw), .clock(clock), .reset_n(reset_n), .width(width), .height(height), .x_pos(x_pos), .y_pos(y_pos), .draw_done(draw_done), .enable(enable), .complete_bounds(complete_bounds));
	
	drawable top(
	.clock(clock), .enable(enable), .reset_n(reset_draw), 
	.height(height), .width(width), 
	.x_pos(x_pos), .y_pos(y_pos), .colour(colour),
	.x_out(x_out), .y_out(y_out), .colour_out(colour_out), 
	.enable_fcounter(enable_fcounter), .y_count_done(draw_done));
	
	

endmodule

module control_boundaries(colour, signal_go, reset_draw, clock, reset_n, width, height, x_pos, y_pos, draw_done, enable, writeEn, complete_bounds);
	 input clock, reset_n, signal_go;
	 output reg enable, writeEn, reset_draw, complete_bounds;
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
					 START = 4'd6,
					 END = 4'd7;
					 
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
					 BOTTOM_RIGHT: next_state = (draw_done == 1) ? END : BOTTOM_RIGHT;
					 END: next_state = END;
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
		  
		  reset_draw <= 0;
		  colour <= 3'b010;
		  
		  complete_bounds <= 0;
		  
        case (curr_state)
				START:
					reset_draw <= 1;
		  
            TOP: begin
						width <= 320;
						height <= 4;
						x_pos <= 0;
						y_pos <= 0;
						enable <= 1'b1;
						 colour <= 3'b010;
                end
				BOTTOM: begin
					   width <= 320;
						height <= 4;
						x_pos <= 0;
						y_pos <= 236;
						enable <= 1'b1;
						 colour <= 3'b010;


                end
            TOP_LEFT: begin
                  width <= 4;
						height <= 90;
						x_pos <= 0;
						y_pos <= 0;
						enable <= 1'b1;
						 colour <= 3'b010;

                end
				BOTTOM_LEFT: begin
				      width <= 4;
						height <= 120;
						x_pos <= 0;
						y_pos <= 150;
						enable <= 1'b1;
						 colour <= 3'b010;

                end
				TOP_RIGHT: begin
					   width <= 4;
						height <= 90;
						x_pos <= 316;
						y_pos <= 0;
						enable <= 1'b1;
						 colour <= 3'b010;

                end
				BOTTOM_RIGHT: begin
					   width <= 4;
						height <= 120;
						x_pos <= 316;
						y_pos <= 150;
						enable <= 1'b1;
						colour <= 3'b010;

                end
				END: begin
					 complete_bounds <= 1;

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


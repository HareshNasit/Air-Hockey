module paddle_sim(
	 clock, reset_n, go,
	 p1_up, p1_down, p1_left, p1_right,
	 p2_up, p2_down, p2_left, p2_right,
	 x, y, colour_out, writeEn);
	 
	 input clock, reset_n, go;
	 input p1_up, p1_down, p1_left, p1_right;
	 input p2_up, p2_down, p2_left, p2_right;
	 
	 output writeEn;
	 output [10:0] x, y;
	 output [2:0] colour_out;
	 
	 wire p1_enDraw, p2_enDraw, ball_enDraw, bounds_enDraw, reset_fsm,
		p1_finYcount, p2_finYcount, ball_finYcount, bounds_finYcount,
		enable_framecounter, erase_start, clear_framecounter, enable_update;
		
	 wire [10:0] p1_x, p1_y;
	 wire [10:0] p2_x, p2_y;
	 wire [10:0] ball_x, ball_y;
	 wire [10:0] bounds_x, bounds_y;

	 
	 wire [2:0] colour_1, colour_2, colour_ball, colour_bounds;
	 wire [2:0] colour;
	 
	 xymux xy(
		.clock(clock),
		.p1_enDraw(p1_enDraw), .p2_enDraw(p2_enDraw), .ball_enDraw(ball_enDraw), .bounds_enDraw(bounds_enDraw),
		.p1_x(p1_x), .p1_y(p1_y), .p1_colour(colour_1),
		.p2_x(p2_x), .p2_y(p2_y), .p2_colour(colour_2), 
		.ball_x(ball_x), .ball_y(ball_y), .ball_colour(colour_ball),
		.bounds_x(bounds_x), .bounds_y(bounds_y), .bounds_colour(colour_bounds),
		.x(x), .y(y), .colour_out(colour_out)
	 );
	 
	 boundaries bounds(
		.signal_go(bounds_enDraw), .clock(clock), .reset_n(reset_fsm), 
		.x_out(bounds_x), .y_out(bounds_y), .colour_out(colour_bounds), 
		.complete_bounds(bounds_finYcount));
	 
	 ball b0(
		.clock(clock), .reset_n(reset_fsm), 
		.x_in(160), .y_in(120), .colour_in(colour), 
		.p1_x(p1_x), .p1_y(p1_y), .p2_x(p2_x), .p2_y(p2_y),
		.x_out(ball_x), .y_out(ball_y), .colour_out(colour_ball), 
		.enable(ball_enDraw), .enable_fcounter(enable_framecounter), .enable_update(enable_update), .y_count_done(ball_finYcount));
	 
	 paddletest p1(
		.clock(clock), .reset_n(reset_fsm), .y_count_done(p1_finYcount), .enable(p1_enDraw),
		.x_in(20), .y_in(80), .colour_in(colour), .enable_fcounter(enable_framecounter),
		.x_out(p1_x), .y_out(p1_y), .colour_out(colour_1), .enable_update(enable_update),
		.enable_up(p1_up), .enable_down(p1_down), .enable_left(p1_left), .enable_right(p1_right));
		
	 paddletest p2(
		.clock(clock), .reset_n(reset_fsm), .y_count_done(p2_finYcount), .enable(p2_enDraw),
		.x_in(200), .y_in(80), .colour_in(colour), .enable_fcounter(enable_framecounter),
		.x_out(p2_x), .y_out(p2_y), .colour_out(colour_2), .enable_update(enable_update),
		.enable_up(p2_up), .enable_down(p2_down), .enable_left(p2_left), .enable_right(p2_right));
	 
	 paddle_animation pa(
		.clock(clock), .reset_n(reset_n), .reset_fsm(reset_fsm), .go(go),
		.p1_enDraw(p1_enDraw), .p2_enDraw(p2_enDraw), .ball_enDraw(ball_enDraw), .bounds_enDraw(bounds_enDraw),
		.p1_finYcount(p1_finYcount), .p2_finYcount(p2_finYcount), .ball_finYcount(ball_finYcount), .bounds_finYcount(bounds_finYcount),
		.enable_framecounter(enable_framecounter), .erase_start(erase_start), .clear_framecounter(clear_framecounter),
		.enable_update(enable_update), .writeEn(writeEn), .colour(colour));
		 
	 
	frame_counter f1(
		.clock(clock), .enable(enable_framecounter), 
		.resetn(reset_fsm), .signal_out(erase_start), 
		.clear_sig(clear_framecounter));
	 
endmodule

module xymux(clock,
	p1_enDraw, p2_enDraw, ball_enDraw, bounds_enDraw,
	p1_x, p1_y, p1_colour,
	p2_x, p2_y, p2_colour,
	ball_x, ball_y, ball_colour,
	bounds_x, bounds_y, bounds_colour,
	x, y, colour_out);
	
	input clock;
	input p1_enDraw, p2_enDraw, ball_enDraw, bounds_enDraw;
	input [10:0] p1_x, p1_y;
	input [10:0] p2_x, p2_y;
	input [10:0] ball_x, ball_y;
	input [10:0] bounds_x, bounds_y;
	
	input [2:0] p1_colour, p2_colour, ball_colour, bounds_colour;
	
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
	p1_enDraw, p2_enDraw, ball_enDraw, bounds_enDraw,
	p1_finYcount, p2_finYcount, ball_finYcount, bounds_finYcount,
	enable_framecounter, erase_start, 
	clear_framecounter, writeEn, enable_update);
	
	input clock, reset_n, go;
	input p1_finYcount, p2_finYcount, ball_finYcount, bounds_finYcount;
	
	output reg p1_enDraw, p2_enDraw, ball_enDraw, bounds_enDraw;
	
	input erase_start;
	output reg enable_framecounter, clear_framecounter;
	output reg writeEn, enable_update, reset_fsm;
	
	output reg [2:0] colour;

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
                UPDATE = 4'd9;
					 
					 
	// Next state logic aka our stRESET_COUNTERate table
    always@(*)
    begin: state_table 
            case (curr_state)
					 START:  next_state = (go == 1) ? DRAWBOUNDS: START; 
					 DRAWBOUNDS: next_state = (bounds_finYcount == 1) ? DRAWP1: DRAWBOUNDS;
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
		  writeEn <= 0;
		  
		  reset_fsm <= 0;
		  
		  enable_framecounter<= 0;
		  clear_framecounter<= 0;
		  
		  colour <= 3'b000;
		  enable_update <= 0;
		  
        case (curr_state)
				START: begin
					 reset_fsm <= 1;
					 
                end
			   DRAWBOUNDS: begin
					 bounds_enDraw <= 1;
					 writeEn <= 1;
					 //colour <= 3'b101;
					 
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
        if(reset_n)
            curr_state <= START;
        else
            curr_state <= next_state;
    end // state_FFS
endmodule

module ball(clock, reset_n, x_in, y_in, colour_in, x_out, y_out, colour_out, enable, enable_fcounter, enable_update, y_count_done,
	p1_x, p1_y, p2_x, p2_y
);
   
	input clock, reset_n, enable, enable_fcounter, enable_update;
	input p1_x, p1_y, p2_x, p2_y;
	
	input [10:0] x_in, y_in;
	input [2:0] colour_in;
	
	output [10:0] x_out, y_out;
	output [2:0] colour_out;
	output y_count_done;
	
	wire [10:0] x_pos, y_pos;
	
	  
	collision2 col(
	 .enable(enable_update), .reset_n(reset_n), .clock(clock), 
	 .x_ball(x_in), .y_ball(y_in),
	 .x_ball_out(x_pos), .y_ball_out(y_pos),
	 .x_paddle1(p1_x), .y_paddle1(p1_y), .x_paddle2(p2_x), .y_paddle2(p2_y)
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

module collision2(clock, enable, reset_n, x_ball, y_ball, x_paddle1, y_paddle1, x_paddle2, y_paddle2, x_ball_out, y_ball_out);
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
	
	reg horizontal;
	reg vertical;
	
	always @(posedge clock)
	begin
		if (reset_n) begin
			x_ball_inside <= x_ball;
			y_ball_inside <= y_ball;
			horizontal <= 1;
			vertical <= 1;
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
			else if (y_ball_inside  == 218) begin
				vertical <= 1;
			end
		
		//Paddles
			if (x_paddle1 <= x_ball_inside && x_ball_inside <= (x_paddle1 + 4)) 
		begin
			if (y_paddle1 <= y_ball_inside && y_ball_inside <= (y_paddle1 + 40))
			begin
				vertical <= ~vertical;
				horizontal <= ~horizontal;
			end
		end
		if (x_paddle2 <= x_ball_inside && x_ball_inside <= (x_paddle2 + 4)) 
		begin
			if (y_paddle2 <= y_ball_inside && y_ball_inside <= (y_paddle2 + 40))
			begin
				vertical <= ~vertical;
				horizontal <= ~horizontal;
			end
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
						height <= 100;
						x_pos <= 0;
						y_pos <= 0;
						enable <= 1'b1;
						 colour <= 3'b010;

                end
				BOTTOM_LEFT: begin
				      width <= 4;
						height <= 120;
						x_pos <= 0;
						y_pos <= 120;
						enable <= 1'b1;
						 colour <= 3'b010;

                end
				TOP_RIGHT: begin
					   width <= 4;
						height <= 100;
						x_pos <= 316;
						y_pos <= 0;
						enable <= 1'b1;
						 colour <= 3'b010;

                end
				BOTTOM_RIGHT: begin
					   width <= 4;
						height <= 120;
						x_pos <= 316;
						y_pos <= 120;
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
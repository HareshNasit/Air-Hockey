module paddle_sim(
	 clock, reset_n, 
	 p1_up, p1_down, p1_left, p1_right,
	 p2_up, p2_down, p2_left, p2_right,
	 x, y, colour_out, writeEn);
	 
	 input clock, reset_n;
	 input p1_up, p1_down, p1_left, p1_right;
	 input p2_up, p2_down, p2_left, p2_right;
	 
	 output writeEn;
	 output [10:0] x, y;
	 output [2:0] colour_out;
	 
	 wire p1_enDraw, p2_enDraw, 
		p1_finYcount, p2_finYcount,
		enable_framecounter, erase_start, clear_framecounter, enable_update;
		
	 wire [10:0] p1_x, p1_y;
	 wire [10:0] p2_x, p2_y;
	 
	 wire [2:0] colour_1, colour_2;
	 wire [2:0] colour;
	 
	 xymux xy(
		.clock(clock),
		.p1_enDraw(p1_enDraw), .p2_enDraw(p2_enDraw), 
		.p1_x(p1_x), .p1_y(p1_y), .p1_colour(colour_1),
		.p2_x(p2_x), .p2_y(p2_y), .p2_colour(colour_2), 
		.x(x), .y(y), .colour_out(colour_out)
	 );
	 
	 paddletest p1(
		.clock(clock), .reset_n(reset_n), .y_count_done(p1_finYcount), .enable(p1_enDraw),
		.x_in(20), .y_in(80), .colour_in(colour), .enable_fcounter(enable_framecounter),
		.x_out(p1_x), .y_out(p1_y), .colour_out(colour_1), .enable_update(enable_update),
		.enable_up(p1_up), .enable_down(p1_down), .enable_left(p1_left), .enable_right(p1_right));
		
	 paddletest p2(
		.clock(clock), .reset_n(reset_n), .y_count_done(p2_finYcount), .enable(p2_enDraw),
		.x_in(200), .y_in(80), .colour_in(colour), .enable_fcounter(enable_framecounter),
		.x_out(p2_x), .y_out(p2_y), .colour_out(colour_2), .enable_update(enable_update),
		.enable_up(p2_up), .enable_down(p2_down), .enable_left(p2_left), .enable_right(p2_right));
	 
	 paddle_animation pa(
		.clock(clock), .reset_n(reset_n),
		.p1_enDraw(p1_enDraw), .p2_enDraw(p2_enDraw), 
		.p1_finYcount(p1_finYcount), .p2_finYcount(p2_finYcount),
		.enable_framecounter(enable_framecounter), .erase_start(erase_start), .clear_framecounter(clear_framecounter),
		.enable_update(enable_update), .writeEn(writeEn), .colour(colour));
		 
	 
	frame_counter f1(
		.clock(clock), .enable(enable_framecounter), 
		.resetn(reset_n), .signal_out(erase_start), 
		.clear_sig(clear_framecounter));
	 
endmodule

module xymux(clock,
	p1_enDraw, p2_enDraw, 
	p1_x, p1_y, p1_colour,
	p2_x, p2_y, p2_colour, 
	x, y, colour_out);
	
	input clock;
	input p1_enDraw, p2_enDraw;
	input [10:0] p1_x, p1_y;
	input [10:0] p2_x, p2_y;
	
	input [2:0] p1_colour, p2_colour;
	
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
			if (enable_up) begin
				y_pos <= y_pos - 1;
			end
			
			if (enable_down) begin
				y_pos <= y_pos + 1;
			end
			
			if (enable_right) begin
				x_pos <= x_pos + 1;
			end
			
			if (enable_left) begin
				x_pos <= x_pos - 1;
			end
		end
	end
	
	assign x_pos_out = x_pos;
	assign y_pos_out = y_pos;

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
 
module paddle_animation(clock, reset_n, colour,
	p1_enDraw, p2_enDraw, 
	p1_finYcount, p2_finYcount,
	enable_framecounter, erase_start, clear_framecounter, writeEn, enable_update);
	
	input clock, reset_n;
	input p1_finYcount, p2_finYcount;
	
	output reg p1_enDraw, p2_enDraw;
	
	input erase_start;
	output reg enable_framecounter, clear_framecounter;
	output reg writeEn, enable_update;
	
	output reg [2:0] colour;

	 reg [3:0] curr_state, next_state;
	 
	 localparam  DRAWP1 = 4'd0,
					 DRAWP2 = 4'd1,
                RESET_COUNTER = 4'd2,
                ERASEP1 = 4'd3,
					 ERASEP2 = 4'd4,
                UPDATE = 4'd5;
					 
	// Next state logic aka our stRESET_COUNTERate table
    always@(*)
    begin: state_table 
            case (curr_state)
                DRAWP1: next_state = (p1_finYcount == 1) ? DRAWP2: DRAWP1; 
					 DRAWP2: next_state = (p2_finYcount == 1) ? RESET_COUNTER: DRAWP2; 
                RESET_COUNTER: next_state = (erase_start == 1) ? ERASEP1 : RESET_COUNTER;
                ERASEP1: next_state  = (p1_finYcount == 1) ? ERASEP2: ERASEP1;
					 ERASEP2: next_state  = (p2_finYcount == 1) ? UPDATE: ERASEP2;
                UPDATE: next_state = DRAWP1;
            default: next_state = DRAWP1;
        endcase
    end // state_table
	 
	 // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signalsmodule 
        // By default make all our signals 0
		  p1_enDraw <= 0;  
		  p2_enDraw <= 0; 
		  writeEn <= 0;
		  
		  enable_framecounter<= 0;
		  clear_framecounter<= 0;
		  
		  colour <= 3'b000;
		  enable_update <= 0;
		  
        case (curr_state)
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
            curr_state <= DRAWP1;
        else
            curr_state <= next_state;
    end // state_FFS
endmodule

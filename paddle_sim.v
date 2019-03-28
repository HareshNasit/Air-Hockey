module paddle_sim(
	 clock, reset_n, 
	 p1_up, p1_down, p1_left, p1_right,
	 p2_up, p2_down, p2_left, p2_right,
	 writeEn);
	 
	 input clock, reset_n;
	 input p1_up, p1_down, p1_left, p1_right;
	 input p2_up, p2_down, p2_left, p2_right;
	 
	 output writeEn;
	 
	 wire p1_enDraw, p2_enDraw, 
		p1_finYcount, p2_finYcount,
		enable_framecounter, erase_start, clear_framecounter, enable_update;
		
	 wire [10:0] p1_x, p1_y;
	 wire [10:0] p2_x, p2_y;
	 
	 wire [2:0] colour_1, colour_2;
	 wire [2:0] colour;
	 
	 paddle p1(
		.clock(clock), .reset_n(reset_n), .y_count_done(p1_finYcount),
		.x_in(20), .y_in(80), .colour_in(colour), .enable_fcounter(enable_framecounter),
		.x_out(p1_x), .y_out(p1_y), .colour_out(colour_1), .enable_update(enable_update),
		.enable_up(p1_up), .enable_down(p1_down), .enable_left(p1_left), .enable_right(p1_right));
		
	 paddle p2(
		.clock(clock), .reset_n(reset_n), .y_count_done(p2_finYcount),
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
					 colour <= 3'b101;
					 
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
endmodules

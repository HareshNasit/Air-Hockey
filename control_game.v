module control_game(clock, reset_n, draw_bounds, draw_ball, done_bounds);
	 input clock, reset_n, done_bounds;
	 
	 output reg draw_bounds, draw_ball;
	 
	 reg [3:0] curr_state, next_state;

	 
	 localparam  CREATE_BOUNDS        = 4'd0,
                START_BALL   = 4'd1,
					 START = 4'd2;
					 
	// Next state logic aka our stRESET_COUNTERate table
	
	//CONSIDER WAITING STATES
    always@(*)
    begin: state_table
            case (curr_state)
					 START: next_state =  (draw_bounds == 1) ? CREATE_BOUNDS: START;
					 CREATE_BOUNDS: next_state = (done_bounds == 1) ? START_BALL : CREATE_BOUNDS;
                START_BALL: next_state = START_BALL; 
            default: next_state = CREATE_BOUND;
        endcase
    end // state_table
	 
	 // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signalsmodule 
        // By default make all our signals 0
		  draw_bounds <= 0;
		  draw_ball <= 0;
		  
        case (curr_state)
				
          CREATE_BOUNDS: begin
					draw_bounds <= 1;
           end
			  
			 START_BALL: begin
					 draw_ball <= 1;
			  end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
	 // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(reset_n)
            curr_state <= CREATE_BOUND;
        else
            curr_state <= next_state;
    end // state_FFS
endmodule
module lcd_top(BTNC,			   
			   BTNR,			   
			   BTND,			   
			   BTNL,			   
			   LD0,
			   LD1,
			   LD2,
			   LD3);
		
	/* switch C is reset, E is clear, S is resetFSM, W is nextString */
	input	   BTNC, BTNR, BTND, BTNL;	
	output	   LD0, LD1, LD2, LD3;
	
	assign LD0 = BTNC;
	assign LD1 = BTNL;
	assign LD2 = BTNR;
	assign LD3 = BTND;

endmodule
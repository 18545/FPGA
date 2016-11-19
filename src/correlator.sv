`include "constants.vh"

module correlator (
	input logic clk, rst_n,
	input logic [3:0] frame_pixel,
	input logic static_bram_rdy,
	input logic [`TEMPLATE_SIZE-1:0][`TEMPLATE_SIZE-1:0][3:0] template_reg,
	input logic [9:0] left, right, top, bottom, c_x, c_y,
	input logic tracking_mode,
	output logic max_ready,
	output logic [18:0] static_read_address,
	output logic [9:0] max_x, max_y
	);
	
	logic [`TEMPLATE_SIZE - 1:0][`TEMPLATE_SIZE - 1:0][3:0] buffer_out;
	logic [18:0] current_response, max_response, write_address;
	logic [9:0] read_x, read_y;
	logic in_box;
	shift_register pixel_buffer (
		.clk(clk),
		.rst_n(rst_n),
		.in(frame_pixel),
		.out(buffer_out)
		);
	
	always_comb begin
		logic [5:0] row, col;
		current_response = 0;
		for (row = 0; row < `TEMPLATE_SIZE; row = row + 1) begin
			for (col = 0; col < `TEMPLATE_SIZE; col = col + 1) begin
				current_response = current_response + ((template_reg[row][col]- buffer_out[row][col])*
														(template_reg[row][col]- buffer_out[row][col]));
			end
		end
	end

	// assign read_x = static_read_address%`VGA_WIDTH;
    // assign read_y = (static_read_address - read_x)/`VGA_WIDTH;

    assign static_read_address = read_y*`VGA_WIDTH + read_x;

    assign in_box = (read_y >= top && read_y <= bottom && read_x >= left && read_x <= right);
    assign on_screen = (read_y >= 10 && read_y <= 470 && read_x >= 10 && read_x <= 630);

	always_ff @(posedge clk) begin
		if(~rst_n || ~tracking_mode) begin
			max_response <= {19{1'b1}};
			max_x <= c_x;
			max_y <= c_y;
		end else if(max_ready) begin
			max_response <= {19{1'b1}};
		end	else if ((current_response < max_response) && on_screen && 
					 ((max_response - current_response) > `MAX_THRESHOLD)) begin
			max_response <= current_response;
			max_x <= read_x - `TEMPLATE_SIZE/2;
			max_y <= read_y - `TEMPLATE_SIZE/2;
		end 
	end

	logic reg_rdy,static_bram_rdy_posedge_pulse;

	//Pulse Generate
	always_ff @(posedge clk) begin
		if(~rst_n) begin
			reg_rdy <= 0;
		end else begin
			reg_rdy <= static_bram_rdy;
		end
	end



	assign static_bram_rdy_posedge_pulse =  static_bram_rdy && ~reg_rdy;


	always_ff @(posedge clk) begin
		if (~rst_n) begin
			// write_address <= 0;
			max_ready <= 0;
			// read_x <= 10;
			// read_y <= 0;
			if (c_x < `SEARCH_WIDTH) read_x <= 10;
			else if (c_x > `VGA_WIDTH - `SEARCH_WIDTH) read_x <= `VGA_WIDTH - (2 * `SEARCH_WIDTH);
			else read_x <= c_x - `SEARCH_WIDTH; 
			if (c_y < `SEARCH_WIDTH) read_y <= 0;
			else if (c_y > `VGA_HEIGHT - `SEARCH_WIDTH) read_y <= `VGA_HEIGHT - (2 * `SEARCH_WIDTH);
			else read_y <= c_y - `SEARCH_WIDTH;
		end else begin
			if(static_bram_rdy_posedge_pulse) begin
				// write_address <= 0;
				if (c_x < `SEARCH_WIDTH) read_x <= 10;
				else if (c_x > `VGA_WIDTH - `SEARCH_WIDTH) read_x <= `VGA_WIDTH - (2 * `SEARCH_WIDTH);
				else read_x <= c_x - `SEARCH_WIDTH; 
				if (c_y < `SEARCH_WIDTH) read_y <= 0;
				else if (c_y > `VGA_HEIGHT - `SEARCH_WIDTH) read_y <= `VGA_HEIGHT - (2 * `SEARCH_WIDTH);
				else read_y <= c_y - `SEARCH_WIDTH; 
				//read_x <= 10;
				//read_y <= 0;
				max_ready <= 0;
			end else if( ((read_x == `VGA_WIDTH - 1) || (read_x == c_x + `SEARCH_WIDTH)) &&
						 ((read_y == `VGA_HEIGHT - 1) || (read_y == c_y + `SEARCH_WIDTH)) ) begin
				max_ready <= 1;
			end else if(~max_ready) begin
				if ((read_x == `VGA_WIDTH - 1) || (read_x == c_x + `SEARCH_WIDTH)) begin
	                if (c_x < `SEARCH_WIDTH) read_x <= 10;
					else if (c_x > `VGA_WIDTH - `SEARCH_WIDTH) read_x <= `VGA_WIDTH - (2 * `SEARCH_WIDTH);
					else read_x <= c_x - `SEARCH_WIDTH; 
	                //read_x <= 10;
	                if ((read_y == `VGA_HEIGHT - 1) || (read_y == c_y + `SEARCH_WIDTH)) begin
	                    //read_y <= 0;
	                    if (c_y < `SEARCH_WIDTH) read_y <= 0;
						else if (c_y > `VGA_HEIGHT - `SEARCH_WIDTH) read_y <= `VGA_HEIGHT - (2 * `SEARCH_WIDTH);
						else read_y <= c_y - `SEARCH_WIDTH;
					end 
	                else 
	                    read_y <= read_y + 1;
	                
	            end
	            else begin
	                read_x <= read_x + 1;
	            end
			end
		end
	end

	// assign static_read_address = write_address;


endmodule: correlator

module shift_register (
	input logic clk, rst_n,
	input logic [3:0] in,
	output logic [`TEMPLATE_SIZE - 1:0][`TEMPLATE_SIZE - 1:0][3:0] out
	);
	localparam buffer_size = ((2 * `SEARCH_WIDTH) * (`TEMPLATE_SIZE - 1)) + (`TEMPLATE_SIZE - 1);
	logic [buffer_size:0][3:0] register;

	always_ff @(posedge clk) begin
		if (~rst_n) begin
			register <= 0;
		end
		else register <= {register[buffer_size - 1:0], in};
	end
	logic [5:0] row;
	logic [$clog2(buffer_size):0] row_start, row_end;
	always_comb begin
		for (row = 0; row <`TEMPLATE_SIZE; row = row + 1) begin
			//row_start = buffer_size - (`VGA_WIDTH * row);
			//row_end = row_start - (`TEMPLATE_SIZE - 1);
			out[row] = register[buffer_size - ((2 * `SEARCH_WIDTH) * row) -: (`TEMPLATE_SIZE - 1)];
		end
	end

endmodule: shift_register
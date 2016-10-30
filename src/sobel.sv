module sobel (
	input logic clk, rst_n,
	input logic [3:0] frame_pixel,
	input logic static_bram_rdy,
	output logic write_enable,
	output logic [3:0] filter_pixel,
	output logic [18:0] write_address,static_read_address
	);
	
	logic [2:0][2:0][3:0] buffer_out;
	logic [3:0] filter_pixel_raw;
	shift_register pixel_buffer (
		.clk(clk),
		.rst_n(rst_n),
		.in(frame_pixel),
		.out(buffer_out)
		);
	
	always_comb begin
		filter_pixel_raw =  -1*buffer_out[0][0]+1*buffer_out[0][2]+
						-2*buffer_out[1][0]+2*buffer_out[1][2]+
						-1*buffer_out[2][0]+1*buffer_out[2][2];
		filter_pixel = (filter_pixel_raw>8) ? 15 : 0;
	end

	//assign filter_pixel = buffer_out[1][1];


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
			write_address <= 0;
			write_enable <= 1;
		end else begin
			if(static_bram_rdy_posedge_pulse) begin
				write_address <= 0;
				write_enable <= 1;
			end else if(write_address == (640*480)-1) begin
				write_enable <= 0;
			end else if(write_enable) begin
				write_address <= write_address + 1;
			end
		end
	end

	assign static_read_address = write_address;


endmodule: sobel

module shift_register #(parameter IMAGEWIDTH=640, FILTERWIDTH=3, FILTERHEIGHT=3)(
	input logic clk, rst_n,
	input logic [3:0] in,
	output logic [2:0][2:0][3:0] out
	);
	
	logic [1282:0][3:0] register;

	always_ff @(posedge clk) begin
		if (~rst_n) begin
			register <= 0;
		end
		else register <= {register[1281:0], in};
	end
	assign out[0] = register[1282:1280];
	assign out[1] = register[642:640];
	assign out[2] = register[2:0];


endmodule: shift_register
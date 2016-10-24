module sobel (
	input logic clk, rst_n,
	input logic [3:0] frame_pixel,
	input logic [18:0] capture_address,
	output logic write_enable,
	output logic [3:0] filter_pixel,
	output logic [18:0] write_address
	);
	
	logic [2:0][2:0][3:0] buffer_out;

	shift_register pixel_buffer (
		.clk(clk),
		.rst_n(rst_n),
		.in(frame_pixel),
		.out(buffer_out)
		);
	/*
	always_comb begin
		filter_pixel =  -1*buffer_out[0][0]+1*buffer_out[0][2]+
						-2*buffer_out[1][0]+2*buffer_out[1][2]+
						-1*buffer_out[2][0]+1*buffer_out[2][2];
	end*/
	assign filter_pixel = buffer_out[1][1];



	always_ff @(posedge clk) begin
		if (~rst_n) begin
			write_address <= capture_address;
			write_enable <= 1;
		end else begin
			write_enable <= 1;
			if(write_address == (640*480)-1) begin
				write_address <= 0;
			end else begin
				write_address <= write_address + 1;
			end

		end

	end



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
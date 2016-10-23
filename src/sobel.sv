module sobel (
	input logic clk,
	input logic [3:0] frame_pixel,
	output logic write_enable,
	output logic [18:0] address
	);
	
	always_ff @(posedge clk) begin
	
	end

endmodule: sobel

module shift_register (
	input logic clk,
	input logic [3:0] in,
	output logic [2:0][2:0][3:0] out
	);

	reg [1282:0][3:0] register

	always_ff @(posedge clk)
		register <= {register[1281:0], in}
	assign out[0] = register[1282:1280]
	assign out[1] = register[642:640]
	assign out[2] = register[2:0]

endmodule: shift_register
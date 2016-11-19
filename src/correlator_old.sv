`define TEMPLATE_SIZE 3
`define VGA_WIDTH 640
`define VGA_HEIGHT 480

module correlator (
    input logic clk, rst_n,
    input logic [3:0] frame_pixel,
    input logic static_bram_rdy,
    input logic [`TEMPLATE_SIZE-1:0][`TEMPLATE_SIZE-1:0][3:0] template_reg,
    output logic max_ready,
    output logic [18:0] static_read_address,
    output logic [9:0] max_x, max_y
);

    logic [`TEMPLATE_SIZE - 1:0][`TEMPLATE_SIZE - 1:0][3:0] buffer_out;
    logic [18:0] current_response, max_response, write_address;
    logic [9:0] read_x, read_y;
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
    current_response = current_response + template_reg[row][col] * buffer_out[row][col];
    end
    end
    end

    assign read_x = static_read_address%`VGA_WIDTH;
    assign read_y = (static_read_address - read_x)/`VGA_WIDTH;

    always_ff @(posedge clk) begin
    if(~rst_n) begin
    max_response <= 0;
    max_x <= 0;
    max_y <= 0;
    end else if (current_response > max_response) begin
    max_response <= current_response;
    max_x <= read_x;
    max_y <= read_y;
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
        write_address <= 0;
        max_ready <= 0;
        end else begin
        if(static_bram_rdy_posedge_pulse) begin
        write_address <= 0;
        max_ready <= 0;
        end else if(write_address == (640*480)-1) begin
        max_ready <= 1;
        end else if(~max_ready) begin
        write_address <= write_address + 1;
        end
        end
    end

    assign static_read_address = write_address;


endmodule: correlator

module shift_register #(parameter IMAGEWIDTH=640, FILTERWIDTH=3, FILTERHEIGHT=3)(
input logic clk, rst_n,
input logic [3:0] in,
output logic [FILTERHEIGHT - 1:0][FILTERWIDTH - 1:0][3:0] out
);
    localparam buffer_size = (IMAGEWIDTH * (FILTERHEIGHT - 1)) + (FILTERWIDTH - 1);
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
        for (row = 0; row <FILTERHEIGHT; row = row + 1) begin
            //row_start = buffer_size - (`VGA_WIDTH * row);
            //row_end = row_start - (FILTERWIDTH - 1);
            out[row] = register[buffer_size - (`VGA_WIDTH * row) -: (FILTERWIDTH - 1)];
        end
    end

endmodule: shift_register

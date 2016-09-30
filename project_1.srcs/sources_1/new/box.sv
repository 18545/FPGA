`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 09/28/2016 11:50:35 AM
// Design Name:
// Module Name: box
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

`define TOP 0
`define RIGHT 1
`define BOTTOM 2
`define LEFT 3

`define WIDTH 640
`define HEIGHT 480
`define BOX_WIDTH WIDTH/4
`define BOX_HEIGHT HEIGHT/4
`define START_X WIDTH/2
`define START_Y HEIGHT/2



module box(
    input logic move_up, move_down, move_left, move_right, mode, rst_n,
    input  logic [9:0]  x, y,
    output logic draw_box
    );

    logic [9:0] width, height, c_x, c_y;
    logic [9:0] left, right, top, bottom;

    assign draw_box = (x == left || x == right ||
                       y == top || y == bottom)

    assign top = c_y - height;
    assign bottom = c_y + height;
    assign left = c_x - width;
    assign right = c_x + width;

    assign x_y_mode = mode;
    assign width_height_mode = !mode;

    up_down_counter #(BOX_WIDTH) width_counter(clk, rst_n,
      width_height_mode, move_right, move_left, width);
    up_down_counter #(BOX_HEIGHT) height_counter(clk, rst_n,
      width_height_mode, move_up, move_down, height);
    up_down_counter #(START_X) c_x_counter(clk, rst_n,
      x_y_mode, move_right, move_left, c_x);
    up_down_counter #(START_Y) c_y_counter(clk, rst_n,
      x_y_mode, move_up, move_down, c_y);

endmodule

module up_down_counter
    #(parameter DEFAULT=8'd100) (
    input logic clk, rst_n, clr, en,
    input logic count_up, count_down,
    output logic [9:0] count
    );

    always_ff @(posedge clk) begin
            if (~rst_n)
                count <= DEFAULT;
            else if (clr)
                count <= DEFAULT;
            else if (en) begin
                if (count_up) count <= count + 1'b1;
                else if (count_down) count <= count - 1'b1;
            end
    end
endmodule

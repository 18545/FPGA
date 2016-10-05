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
`define BOX_WIDTH 160
`define BOX_HEIGHT 120
`define START_X 320
`define START_Y 240



module box(
    input logic clk, rst_n,
    input logic move_up, move_down, move_left, move_right, mode,
    input  logic [9:0]  x, y,
    output logic draw_box,
    output logic [3:0] button_down
    );

    logic [9:0] width, height, c_x, c_y;
    logic [9:0] left, right, top, bottom;
    
    assign top_bottom = (y >= top && y <= bottom) && (x == left || x == right);
    assign left_right = (x >= left && x <= right) && (y == top || y == bottom);
    assign draw_box = top_bottom || left_right ;

    assign top = c_y - height;
    assign bottom = c_y + height;
    assign left = c_x - width;
    assign right = c_x + width;

    assign x_y_mode = mode;
    assign width_height_mode = !mode;

    up_down_counter #(160) width_counter(clk, rst_n,
      width_height_mode, move_right, move_left, width, button_down[0]);
    up_down_counter #(120) height_counter(clk, rst_n,
      width_height_mode, move_up, move_down, height, button_down[1]);
    up_down_counter #(320) c_x_counter(clk, rst_n,
      x_y_mode, move_right, move_left, c_x, button_down[2]);
    up_down_counter #(240) c_y_counter(clk, rst_n,
      x_y_mode, move_up, move_down, c_y, button_down[3]);

endmodule

module up_down_counter
    #(parameter DEFAULT=8'd100, MAX=8'd100, MIN=8'd5) (
    input logic clk, rst_n, en,
    input logic count_up, count_down,
    output logic [9:0] count,
    output logic button_down
    );
    
    always_ff @(posedge clk) begin
            if (~rst_n) begin
                count <= DEFAULT;
                button_down <= 0;
            end
            else if (en && !button_down) begin
                if (count_up && (count < MAX)) begin
                     count <= count + 1'b1;
                     button_down <= 1;
                end
                else if (count_down && (count > MIN)) begin
                 count <= count - 1'b1;
                 button_down <= 1;
               end
                
            end
            else if (!count_up && !count_down) begin
                button_down <= 0;
            end
    end
endmodule

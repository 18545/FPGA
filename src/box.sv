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
`define BOX_WIDTH 100
`define BOX_HEIGHT 100
`define START_X 320
`define START_Y 240

`define TEMPLATE_SIZE 40




module box(
    input logic clk, rst_n,
    input logic move_up, move_down, move_left, move_right, mode,
    input  logic [9:0]  x, y, capture_x, capture_y,
    output logic draw_box, in_box, template_in_box
//    output logic [5:0] template_x,template_y
    );

    logic [9:0] width, height, c_x, c_y;
    logic [9:0] left, right, top, bottom;
    logic [9:0] template_top, template_bottom, template_left, template_right;
    
    assign in_box = (y >= top && y <= bottom && x >= left && x <= right);
   // assign capture_in_box = (capture_y >= top && capture_y <= bottom && capture_x >= left && capture_x <= right);
    assign template_in_box = ((y >= template_top) && (y < template_bottom) && 
                             (x >= template_left) && (x < template_right));

    assign top_bottom = (y >= top && y <= bottom) && (x == left || x == right);
    assign left_right = (x >= left && x <= right) && (y == top || y == bottom);
    assign draw_box = top_bottom || left_right ;

    assign top = c_y - height;
    assign bottom = c_y + height;
    assign left = c_x - width;
    assign right = c_x + width;

    assign x_y_mode = mode;
    assign width_height_mode = !mode;

    assign template_top = c_y - `TEMPLATE_SIZE/2;
    assign template_bottom = c_y + `TEMPLATE_SIZE/2;
    assign template_left = c_x - `TEMPLATE_SIZE/2;
    assign template_right = c_x + `TEMPLATE_SIZE/2;

    assign template_x  = x- template_left;
    assign template_y = y - template_top;



    up_down_counter width_counter(clk, rst_n,
      width_height_mode, move_right, move_left, width);
    up_down_counter height_counter(clk, rst_n,
      width_height_mode, move_up, move_down, height);
    up_down_counter #(320, 0, 640) c_x_counter(clk, rst_n,
      x_y_mode, move_right, move_left, c_x);
    up_down_counter #(240, 0, 480) c_y_counter(clk, rst_n,
      x_y_mode, move_down, move_up, c_y);

endmodule

module up_down_counter
    #(parameter DEFAULT=8'd100, MIN=8'd5, MAX=8'd100) (
    input logic clk, rst_n, en,
    input logic count_up, count_down,
    output logic [9:0] count
    );
    
    logic [34:0] button_counter;

    always_ff @(posedge clk) begin
            if (~rst_n) begin
                count <= DEFAULT;
            end
            else if (en && button_counter == 0) begin
                if (count_up && (count < MAX)) begin
                     count <= count + 1'b1;
                end
                else if (count_down && (count > MIN)) begin
                 count <= count - 1'b1;
               end
                
            end
            else if (!count_up && !count_down) begin
                button_counter <= 0;
            end
            button_counter++;
    end
endmodule

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

module box(
    input logic move_up, move_down, move_left, move_right, middle, mode,
    output logic [3:0][9:0] side //0=top, 1=right, 2=bottom, 3=left
    );
    
    logic [3:0] clr, en, count_up, count_down;
    logic [3:0][9:0] count;
    
    up_down_counter width(clk, rst_n, clr[0], en[0], move_right, move_left, count[0]);
    up_down_counter height(clk, rst_n, clr[1], en[1], move_up, move_down, count[1]);
    up_down_counter x(clk, rst_n, clr[2], en[2], move_right, move_left, count[2]);
    up_down_counter y(clk, rst_n, clr[3], en[3], move_up, move_down, count[3]);    
    
endmodule

module up_down_counter(
    input logic clk, rst_n, clr, en, 
    input logic count_up, count_down,
    output logic [9:0] count
    );
    
    always_ff @(posedge clk) begin
            if (~rst_n)
                count <= 'b0;
            else if (clr)
                count <= 'b0;
            else if (en) begin
                if (count_up) count <= count + 1'b1;
                else if (count_down) count <= count - 1'b1;
            end
    end
endmodule

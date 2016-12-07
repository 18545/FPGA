`include "constants.vh"

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

module box(
    input logic clk, rst_n, smooth_mode,
    input logic move_up, move_down, move_left, move_right, mode, max_ready, tracking_mode,
    input  logic [9:0]  x, y, capture_x, capture_y, max_x, max_y,
    output logic draw_box, in_box, template_in_box, template_start,
    output logic [9:0] template_top, template_left,
    output logic [9:0] left, right, top, bottom, c_x, c_y
    );

    logic [9:0] width, height, counter_x, counter_y;
    logic [9:0] template_bottom, template_right, desired_x, desired_y;
    
    assign template_start = (y == template_top && x == template_left);
    assign in_box = (y >= top && y <= bottom && x >= left && x <= right);
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

    assign template_top = c_y - `TEMPLATE_WIDTH/2;
    assign template_bottom = c_y + `TEMPLATE_WIDTH/2;
    assign template_left = c_x - `TEMPLATE_WIDTH/2;
    assign template_right = c_x + `TEMPLATE_WIDTH/2;

    logic [18:0] box_smooth_count;

    always_ff @(posedge clk) begin
        if (tracking_mode) begin
            if (max_ready) begin
                desired_x <= max_x;
                desired_y <= max_y;
                if (~smooth_mode) begin
                    c_x <= max_x;
                    c_y <= max_y;
                end
            end
            box_smooth_count <= box_smooth_count + 1;
            if (box_smooth_count == 0 && smooth_mode) begin
                if (c_x < desired_x) c_x <= c_x + 1;
                else if (c_x > desired_x) c_x <= c_x - 1;
                if (c_y < desired_y) c_y <= c_y + 1;
                else if (c_y > desired_y) c_y <= c_y - 1;
            end
        end else begin
            c_x <= counter_x;
            c_y <= counter_y;
        end
    end

    up_down_counter width_counter(clk, rst_n,
      width_height_mode, move_right, move_left, width);
    up_down_counter height_counter(clk, rst_n,
      width_height_mode, move_up, move_down, height);
    up_down_counter #(`VGA_WIDTH/2, `BOX_WIDTH, (`VGA_WIDTH-`BOX_WIDTH)) c_x_counter(clk, rst_n,
      x_y_mode, move_right, move_left, counter_x);
    up_down_counter #(`VGA_HEIGHT/2, `BOX_WIDTH, (`VGA_HEIGHT-`BOX_WIDTH)) c_y_counter(clk, rst_n,
      x_y_mode, move_down, move_up, counter_y);

endmodule

module up_down_counter
    #(parameter DEFAULT=`BOX_WIDTH, MIN=8'd5, MAX=`BOX_WIDTH) (
    input logic clk, rst_n, en,
    input logic count_up, count_down,
    output logic [9:0] count
    );
    
    logic [19:0] button_counter;

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
            button_counter <= button_counter + 1;
    end
endmodule

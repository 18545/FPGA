/** FILE
 *  vga.sv
 *
 *  BRIEF
 *  Module that acts an an interface for the VGA output.
 *  AUTHOR of VGA code
 *  Anita Zhang (anitazha)
 */

/****** File-wide Colors ***********/
typedef enum logic [23:0] {
    RED      = {8'hFF, 8'h00, 8'h00},
    GREEN    = {8'h00, 8'hFF, 8'h00},
    BLUE     = {8'h00, 8'h00, 8'hFF},
    CYAN     = {8'h00, 8'hFF, 8'hCC},
    PURPLE   = {8'h99, 8'h00, 8'hFF},
    YELLOW   = {8'hFF, 8'hFF, 8'h00},
    BLACK    = {8'h00, 8'h00, 8'h00},
    WHITE    = {8'hFF, 8'hFF, 8'hFF}
} color_t;

/****** File-wide Shapes ***********/
typedef enum logic [2:0] {
    LEFTTOP  = 3'b001,  // blue
    WALL     = 3'b010,  // red
    RIGHTTOP = 3'b011,  // cyan
    EQUAL    = 3'b100,  // purple
    RIGHTBOT = 3'b101,  // green
    LEFTBOT  = 3'b110   // yellow
} shape_t;

/** BRIEF
 *  Main module that handles user input and displays game data.
 */

module mastermindVGA (
    input  logic        GCLK,
    input  logic        BTNC, BTND, BTNU, BTNL, BTNR,
    input logic SW0,SW1,SW2,SW3,SW4,SW5,SW6,SW7,

    output logic        VGA_VS, VGA_HS,
    output logic VGA_B1, VGA_B2, VGA_B3, VGA_B4,
    output logic VGA_G1, VGA_G2, VGA_G3, VGA_G4,
    output logic VGA_R1, VGA_R2, VGA_R3, VGA_R4,
    output logic LD0,LD1,LD2,LD3
    );

    /****************************************
     *       Internal Signals
     ****************************************/

    // other
    (* mark_debug = "true" *) logic                 clk;
    logic clk_50, clk_25,blank;
    logic [9:0] x, y;
    logic [3:0] group1,group2;
    logic [3:0] red,green,blue;
    // renamed signals
    assign clk = clk_50;

    assign reset = BTNC;

    always_ff @(posedge GCLK, posedge reset) begin
        if (reset) clk_50 <= 0;
        else clk_50 <= ~clk_50;
    end

    /****************************************
     *       VGA data
     ****************************************/

    vga vgaCounter (
            .row        (y),
            .col        (x),
            .HS         (VGA_HS),
            .VS         (VGA_VS),
            .blank      (blank),
            .clk_50     (clk_50),
            .reset      (reset));

    assign {VGA_B1, VGA_B2, VGA_B3, VGA_B4} = blue;
    assign {VGA_G1, VGA_G2, VGA_G3, VGA_G4} = green;
    assign {VGA_R1, VGA_R2, VGA_R3, VGA_R4} = red;

    logic isNum1, isNum2, isNum3, isNum4, isNum5;

    logic drawBox;
    logic [3:0] buttonDown;

    always_comb begin
        if(blank) begin
            blue =  4'h0;
            green =  4'h0;
            red =  4'h0;
        end else if(isNum1 | isNum2 | isNum3 | isNum4 | isNum5 | drawBox) begin
            blue =  4'hf;
            green =  4'hf;
            red =  4'hf;
        end else begin
            blue = (SW2) ? 4'hf : 4'h0;
            green = (SW1) ? 4'hf : 4'h0;
            red = (SW0) ? 4'hf : 4'h0;
        end
    end

    box faceBox (
      .move_up (BTNU),
      .move_down (BTND),
      .move_left (BTNL),
      .move_right (BTNR),
      .mode (SW7),
      .clk (clk_50),
      .rst_n (SW6),
      .x (x),
      .y (y),
      .draw_box (drawBox),
      .button_down (buttonDown)
    );

    assign {LD0,LD1,LD2,LD3} = buttonDown;

    drawNumber numDrawer1 (
                    .inNum  (isNum1),
                    .x      (x),
                    .y      (y),
                    .posX   (100),
                    .posY   (100),
                    .value  (1)
                    );

    drawNumber numDrawer2 (
                    .inNum  (isNum2),
                    .x      (x),
                    .y      (y),
                    .posX   (150),
                    .posY   (100),
                    .value  (8)
                    );

    drawNumber numDrawer3 (
                    .inNum  (isNum3),
                    .x      (x),
                    .y      (y),
                    .posX   (200),
                    .posY   (100),
                    .value  (5)
                    );

    drawNumber numDrawer4 (
                    .inNum  (isNum4),
                    .x      (x),
                    .y      (y),
                    .posX   (250),
                    .posY   (100),
                    .value  (4)
                    );

    drawNumber numDrawer5 (
                .inNum  (isNum5),
                .x      (x),
                .y      (y),
                .posX   (300),
                .posY   (100),
                .value  (5)
                );

endmodule: mastermindVGA


/*****************************************************************
 *
 *                    VGA Magic
 *
 *****************************************************************/

/** BRIEF
 *  VGA module that outputs the current hsync and vsync values needed
 *  to display content. Does not handle the actual color content.
 *
 *  Requires the Library.sv modules to work. Supports 640 x 480 px.
 */
module vga (
    output logic [9:0] row, col,
    output logic       HS, VS, blank,
    input  logic       clk_50, reset
    );

    logic [10:0] col_count;
    logic        col_clear, col_enable;
    logic [9:0]  row_count;
    logic        row_clear, row_enable;
    logic        h_blank, v_blank;

    // Row counter counts from 0 to 520
    //     count of   0 - 479 is display time (thus row_count is correct here)
    //     count of 480 - 489 is front porch
    //     count of 490 - 491 is VS=0 pulse width
    //     count of 492 - 520 is back porch

    simple_counter #(10) row_counter(
            .Q      (row_count),
            .en     (row_enable),
            .clr    (row_clear),
            .clk    (clk_50),
            .reset  (reset)
            );

    assign row        = row_count;
    assign row_clear  = (row_count >= 10'd520);
    assign row_enable = (col_count == 11'd1599);
    assign VS         = (row_count < 10'd490) | (row_count > 10'd491);
    assign v_blank    = (row_count >= 10'd480);

    // Col counter counts from 0 to 1599
    //     count of    0 - 1279 is display time (col is div by 2)
    //     count of 1280 - 1311 is front porch
    //     count of 1312 - 1503 is HS=0 pulse width
    //     count of 1504 - 1599 is back porch

    simple_counter #(11) col_counter(
            .Q      (col_count),
            .en     (col_enable),
            .clr    (col_clear),
            .clk    (clk_50),
            .reset  (reset)
            );

    assign col        = col_count[10:1];
    assign col_clear  = (col_count >= 11'd1599);
    assign col_enable = 1'b1;
    assign HS         = (col_count < 11'd1312) | (col_count > 11'd1503);
    assign h_blank    = col_count > 11'd1279;

    assign blank      = h_blank | v_blank;
endmodule: vga

/*****************************************************************
 *
 *                    Library modules
 *
 *****************************************************************/

/** BRIEF
 *  Outputs whether a value lies between [low, high].
 */
module range_check
    #(parameter WIDTH = 4'd10) (
    input  logic [WIDTH-1:0] val, low, high,
    output logic             is_between
    );

    assign is_between = (val >= low) & (val <= high);

endmodule: range_check

/** BRIEF
 *  Outputs whether a value lies between [low, low + delta].
 */
module offset_check
    #(parameter WIDTH = 4'd10) (
    input  logic [WIDTH-1:0] val, low, delta,
    output logic             is_between
    );

    assign is_between = ((val >= low) & (val < (low+delta)));

endmodule: offset_check

/** BRIEF
 *  Simple up counter with synchronous clear and enable.
 *  Clear takes precedence over enable.
 */
module simple_counter
    #(parameter WIDTH = 4'd8) (
    output logic [WIDTH-1:0] Q,
    input  logic             clk, en, clr, reset
    );

    always_ff @(posedge clk, posedge reset)
        if (reset)
            Q <= 'b0;
        else if (clr)
            Q <= 'b0;
        else if (en)
            Q <= (Q + 1'b1);

endmodule: simple_counter

module drawNumber
    #(parameter LINEWIDTH = 10'd4, PADDING = 10'd10, SIDE = 10'd42) (
    output logic        inNum,
    input  logic [9:0]  x, y,
    input  logic [9:0]  posX, posY,
    input  logic [3:0]  value
    );

    // internal signals
    logic   [6:0] isSegX, isSegY, isSeg;

    /****************************************
     *          Output logic
     ****************************************/

    assign isSeg = (isSegX & isSegY);

    always_comb begin
        inNum = 1'b0;

        case (value)
            4'd0: begin
                if (isSeg[5:0] | isSeg[6])
                    inNum = 1'b1;
            end
            4'd1: begin
                if (isSeg[2:1])
                    inNum = 1'b1;
            end
            4'd2: begin
                if (isSeg[0] | isSeg[1] | isSeg[6] | isSeg[4] | isSeg[3])
                    inNum = 1'b1;
            end
            4'd3: begin
                if (isSeg[3:0] || isSeg[6])
                    inNum = 1'b1;
            end
            4'd4: begin
                if (isSeg[6:5] || isSeg[2:1])
                    inNum = 1'b1;
            end
            4'd5: begin
                if (isSeg[6:5] || isSeg[3:2] || isSeg[0])
                    inNum = 1'b1;
            end
            4'd6: begin
                if (isSeg[6:2] || isSeg[0])
                    inNum = 1'b1;
            end
            4'd7: begin
                if (isSeg[2:0])
                    inNum = 1'b1;
            end
            4'd8: begin
                if (isSeg[6:0])
                    inNum = 1'b1;
            end
            4'd9: begin
                if (isSeg[3:0] || isSeg[6:5])
                    inNum = 1'b1;
            end                        
        endcase
    end

    /****************************************
     *          Segment Boundary Check
     ****************************************/

    // top segment
    offset_check #(10) segCheckX0 (
            .val        (x),
            .low        (posX + PADDING),
            .delta      (SIDE - (2*PADDING)),
            .is_between (isSegX[0]));

    offset_check #(10) segCheckY0 (
            .val        (y),
            .low        (posY + PADDING),
            .delta      (LINEWIDTH),
            .is_between (isSegY[0]));

    // top right segment
    offset_check #(10) segCheckX1 (
            .val        (x),
            .low        (posX + (SIDE - PADDING) - LINEWIDTH),
            .delta      (LINEWIDTH),
            .is_between (isSegX[1]));

    offset_check #(10) segCheckY1 (
            .val        (y),
            .low        (posY + PADDING),
            .delta      ((SIDE - (PADDING*2))/2),
            .is_between (isSegY[1]));

    // bottom right segment
    offset_check #(10) segCheckX2 (
            .val        (x),
            .low        (posX + (SIDE - PADDING) - LINEWIDTH),
            .delta      (LINEWIDTH),
            .is_between (isSegX[2]));

    offset_check #(10) segCheckY2 (
            .val        (y),
            .low        (posY + PADDING + ((SIDE - (2*PADDING))/2)),
            .delta      ((SIDE - (PADDING*2))/2),
            .is_between (isSegY[2]));

    // bottom segment
    offset_check #(10) segCheckX3 (
            .val        (x),
            .low        (posX + PADDING),
            .delta      (SIDE - (2*PADDING)),
            .is_between (isSegX[3]));

    offset_check #(10) segCheckY3 (
            .val        (y),
            .low        (posY + (SIDE - PADDING) - LINEWIDTH),
            .delta      (LINEWIDTH),
            .is_between (isSegY[3]));

    // bottom left segment
    offset_check #(10) segCheckX4 (
            .val        (x),
            .low        (posX + PADDING),
            .delta      (LINEWIDTH),
            .is_between (isSegX[4]));

    offset_check #(10) segCheckY4 (
            .val        (y),
            .low        (posY + PADDING + ((SIDE - (2*PADDING))/2)),
            .delta      ((SIDE - (PADDING*2))/2),
            .is_between (isSegY[4]));

    // top left segment
    offset_check #(10) segCheckX5 (
            .val        (x),
            .low        (posX + PADDING),
            .delta      (LINEWIDTH),
            .is_between (isSegX[5]));

    offset_check #(10) segCheckY5 (
            .val        (y),
            .low        (posY + PADDING),
            .delta      ((SIDE - (PADDING*2))/2),
            .is_between (isSegY[5]));

    // middle segment
    offset_check #(10) segCheckX6 (
            .val        (x),
            .low        (posX + PADDING),
            .delta      (SIDE - (2*PADDING)),
            .is_between (isSegX[6]));

    offset_check #(10) segCheckY6 (
            .val        (y),
            .low        (posY + (SIDE/2) - LINEWIDTH/2),
            .delta      (LINEWIDTH),
            .is_between (isSegY[6]));

endmodule: drawNumber

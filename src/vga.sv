/** FILE
 *  vga.sv
 *
 *  BRIEF
 *  Module that acts an an interface for the VGA output.
 *  AUTHOR of VGA code
 *  Anita Zhang 2 (anitazha)
 */
`define TEMPLATE_SIZE 40
`define WHITE 4'hf
`define VGA_WIDTH 640
`define VGA_HEIGHT 480
`define TEMPLATE_DISPLAY_TOP (`VGA_HEIGHT/2 - `TEMPLATE_SIZE/2)
`define TEMPLATE_DISPLAY_LEFT (`VGA_WIDTH/2 - `TEMPLATE_SIZE/2)

/** BRIEF
 *  Main module that handles user input and displays game data.
 */

module top (
    input  logic        GCLK,
    input  logic        BTNC, BTND, BTNU, BTNL, BTNR,
    input logic SW0,SW1,SW2,SW3,SW4,SW5,SW6,SW7,
    output logic OV7670_SIOC,    
    inout  logic OV7670_SIOD, 
    output OV7670_RESET,  
    output OV7670_PWDN,  
    input  OV7670_VSYNC,  
    input logic OV7670_HREF,       
    input logic OV7670_PCLK, 
    output logic OV7670_XCLK,
    input logic [7:0] OV7670_D,

    output logic        VGA_VS, VGA_HS,
    output logic VGA_B1, VGA_B2, VGA_B3, VGA_B4,
    output logic VGA_G1, VGA_G2, VGA_G3, VGA_G4,
    output logic VGA_R1, VGA_R2, VGA_R3, VGA_R4,
    output logic LD0,LD1,LD2,LD3,LD4,LD5,LD6,LD7
    );

    /****************************************
     *       Internal Signals
     ****************************************/

    logic clk, clk_50, clk_25,blank, clk_100;
    logic [9:0] x, y;
    logic [3:0] red,green,blue;
    logic capture_we, capture_static, sobel_we,capture_static_we;
    logic [18:0] capture_addr, frame_addr, sobel_addr_in,static_read_address;
    logic [11:0] capture_data;
    logic [3:0] frame_pixel_live, frame_pixel_static, frame_pixel_display, frame_pixel_sobel;
    logic [3:0] capture_data_grayscale, capture_data_template, sobel_data_in;
    logic [9:0] capture_x, capture_y;
    logic isNum1, isNum2, isNum3, isNum4, isNum5;
    logic drawBox;
    logic in_box, template_in_box;


    logic template_rdy;
    logic [`TEMPLATE_SIZE-1:0][`TEMPLATE_SIZE-1:0][3:0] template_reg;
    logic [5:0] template_x,template_y;

    // renamed signals
    assign clk = clk_50;

    assign rst_n = SW7;
    assign reset = ~rst_n;

    always_ff @(posedge GCLK) begin
        if (reset) clk_50 <= 0;
        else clk_50 <= ~clk_50;
    end

    always_ff @(posedge clk_50) begin
        if (reset) clk_25 <= 0;
        else clk_25 <= ~clk_25;
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
    
    assign clk_100 = GCLK;
    
    //grayscaled
    assign {VGA_B4, VGA_B3, VGA_B2, VGA_B1} = blue;
    assign {VGA_G4, VGA_G3, VGA_G2, VGA_G1} = green;
    assign {VGA_R4, VGA_R3, VGA_R2, VGA_R1} = red;


    always_comb begin
        if(blank) begin
            blue =  4'h0;
            green =  4'h0;
            red =  4'h0;
        end else if(drawBox) begin
            blue =  `WHITE;
            green =  `WHITE;
            red =  `WHITE;
        end else begin
            blue = frame_pixel_display;
            green = frame_pixel_display;
            red = frame_pixel_display;
        end
    end
    

    box faceBox (
      .move_up (BTNU),
      .move_down (BTND),
      .move_left (BTNL),
      .move_right (BTNR),
      .mode (SW0),
      .clk (clk_50),
      .rst_n (rst_n),
      .x (x),
      .y (y),
      .capture_x (capture_x),
      .capture_y (capture_y),
      .draw_box (drawBox),
      .in_box (in_box),
      .template_in_box (template_in_box)
//      .template_x (template_x),
//      .template_y (template_y)
    );

    assign capture_data_grayscale = (capture_data[11:8] + capture_data[7:4] + capture_data[3:0])/3;
    
    //assign capture_data_template = (template_in_box) ? capture_data_grayscale : 0;

    assign capture_data_template = capture_data_grayscale;

    assign frame_addr = y*`VGA_WIDTH + x;
    
    assign capture_x = capture_addr%`VGA_WIDTH;
    assign capture_y = (capture_addr - capture_x)/`VGA_WIDTH;


    assign capture_static = capture_we && capture_static_we;


    assign LD3 = ~capture_static_we;
    assign LD4 = ~sobel_we;
    assign LD1 = template_in_box;

    //assign frame_pixel_display = (SW2) ? frame_pixel_sobel : frame_pixel_static;

    always_comb begin
        if (SW2) begin
            if (template_in_box)
                frame_pixel_display = template_reg[y-`TEMPLATE_DISPLAY_TOP][x-`TEMPLATE_DISPLAY_LEFT];
            else frame_pixel_display = frame_pixel_sobel;
        end
        else frame_pixel_display = frame_pixel_live;
    end


  trigger_write_en static_bram_we(.clk(clk),
                                    .rst_n(rst_n),
                                    .sobel_we(sobel_we),
                                    .capture_addr(capture_addr),
                                    .capture_static_we(capture_static_we));


    template_capture record_template(
                                    .clk(clk),
                                    .rst_n(rst_n),
                                    .template_in_box(template_in_box),
                                    .capture_switch(SW3),
                                    .capture_data_template(frame_pixel_live),
                                    .template_rdy(template_rdy),
                                    .template_reg(template_reg));

    
    sobel sobel_conv(
                .clk(clk_50),
                .rst_n(rst_n),
                .frame_pixel(frame_pixel_static),
                .static_bram_rdy(~capture_static_we),
                .write_enable(sobel_we),
                .filter_pixel(sobel_data_in),
                .write_address(sobel_addr_in),
                .static_read_address(static_read_address)
                );

    // BLOCK RAMS
    blk_mem_gen_0 mem_gen (
                .clka(OV7670_PCLK),
                .wea(capture_we),
                .addra(capture_addr),
                .dina(capture_data_grayscale),
                .clkb(clk_50),
                .addrb(frame_addr),
                .doutb(frame_pixel_live)
                );


    blk_mem_gen_0 mem_gen_static (
                .clka(OV7670_PCLK),
                .wea(capture_static),
                .addra(capture_addr),
                .dina(capture_data_template),
                .clkb(clk_50),
                .addrb(static_read_address),
                .doutb(frame_pixel_static)
                );

    blk_mem_gen_0 mem_gen_sobel (
                .clka(clk_50),
                .wea(sobel_we),
                .addra(sobel_addr_in),
                .dina(sobel_data_in),
                .clkb(clk_50),
                .addrb(frame_addr),
                .doutb(frame_pixel_sobel)
                );

  

    /*Instantiating VHDL camera modules*/
    logic resend, config_finished;
    assign LD7 = config_finished;
    debounce db (
                .clk(clk_50),
                .i(0),
                .o(resend)
                );

    ov7670_controller controller (
                .clk(clk_50),
                .resend(resend),
                .config_finished(config_finished),
                .siod(OV7670_SIOD),
                .sioc(OV7670_SIOC),
                .reset(OV7670_RESET),
                .pwdn(OV7670_PWDN),
                .xclk(OV7670_XCLK)
                );

    ov7670_capture capture (
                .pclk(OV7670_PCLK),
                .vsync(OV7670_VSYNC),
                .href(OV7670_HREF),
                .d(OV7670_D),
                .addr(capture_addr),
                .dout(capture_data),
                .we(capture_we)
                );

endmodule: top


// module trigger_write_en(
//     input logic clk,rst_n,capture_switch,
//     input logic [18:0] capture_addr,
//     output logic capture_static_we);


//     always_ff @(posedge clk) begin
//         if(~rst_n)
//             capture_static_we <= 1;
//         else if((capture_addr == 640*480-1)&&capture_switch) begin
//             capture_static_we <= 0;
//         end else if(~capture_switch) begin
//             capture_static_we <= 1;
//         end
//     end




// endmodule: trigger_write_en

module trigger_write_en(
    input logic clk,rst_n,sobel_we,
    input logic [18:0] capture_addr,
    output logic capture_static_we);

    logic [18:0] previous_addr;
    always_ff @(posedge clk) begin
        if(~rst_n) begin
            capture_static_we <= 1;
            previous_addr <= 0;
        end else if((capture_addr == `VGA_WIDTH*`VGA_HEIGHT-1) && (capture_addr != previous_addr)) begin
            if (capture_static_we) capture_static_we <= 0;
            else capture_static_we <= ~sobel_we;
        end
        previous_addr <= capture_addr;
    end

endmodule: trigger_write_en

module template_capture(
    input logic clk, rst_n, template_in_box,capture_switch,
    input logic [3:0] capture_data_template,
    // input logic [5:0] template_x,template_y,
    output logic template_rdy,
    output logic [`TEMPLATE_SIZE-1:0][`TEMPLATE_SIZE-1:0][3:0] template_reg);


    logic capturing_template;
    logic [5:0] template_x,template_y;
    logic everyOther;


    always_ff @(posedge clk) begin
        if(~rst_n) begin
            //template_reg <= 0;
            template_x <= 0;
            everyOther <= 1;
            template_y <= 0;
            capturing_template <= 1;
            template_reg[`TEMPLATE_SIZE/4][`TEMPLATE_SIZE/4] <= `WHITE;
            template_reg[`TEMPLATE_SIZE/4][3*`TEMPLATE_SIZE/4] <= `WHITE;
            template_reg[3*`TEMPLATE_SIZE/4][3*`TEMPLATE_SIZE/4] <= `WHITE;
            template_reg[3*`TEMPLATE_SIZE/4][`TEMPLATE_SIZE/4] <= `WHITE;
        end else if(template_in_box && everyOther) begin
            if ((template_x == `TEMPLATE_SIZE - 1)) begin
                template_x <= 0;
                if (template_y == `TEMPLATE_SIZE - 1) 
                    template_y <= 0;
                else 
                    template_y <= template_y + 1;
                
            end
            else begin
                template_x <= template_x + 1;
            end
            template_reg[template_y][template_x] <= capture_data_template;
            
        end
        everyOther <= ~everyOther;


        if(capture_switch && template_y == `TEMPLATE_SIZE - 1) begin
            capturing_template <= 0;
        end else if(~capture_switch) begin
            capturing_template <= 1;
        end
    end


    assign template_rdy = ~capturing_template;


endmodule: template_capture



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
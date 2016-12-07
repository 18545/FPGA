
`include "constants.vh"
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
    input logic J_UP, J_LEFT, J_RIGHT, J_DOWN, J_BUTTON,
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
    logic capture_we, capture_static, sobel_we,capture_static_we;
    logic isNum1, isNum2, isNum3, isNum4, isNum5;
    logic drawBox;
    logic in_box, template_in_box, max_ready;
    logic template_rdy, template_start;

    logic [9:0] x, y, c_x, c_y;
    logic [3:0] red,green,blue;
    logic [18:0] capture_addr, frame_addr, sobel_addr_in,static_read_address;
    logic [11:0] capture_data;
    logic [3:0] frame_pixel_live, frame_pixel_static, frame_pixel_display, frame_pixel_sobel;
    logic [3:0] capture_data_grayscale, capture_data_template, sobel_data_in;
    logic [9:0] capture_x, capture_y, template_top, template_left, max_x, max_y;
    logic [9:0] left, right, top, bottom;
    
    logic [`TEMPLATE_WIDTH-1:0][`TEMPLATE_WIDTH-1:0][3:0] template_reg;



    logic reg_button_press,capture_state;


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
            if (capture_state) begin
                blue =  0;
                green =  0;
                red =  4'hf;
            end else begin
                blue =  `WHITE;
                green =  `WHITE;
                red =  `WHITE;
            end
        end else begin
            blue = frame_pixel_display;
            green = frame_pixel_display;
            red = frame_pixel_display;
        end
    end
    

    box faceBox (
      .move_up (~J_UP),
      .move_down (~J_DOWN),
      .move_left (~J_LEFT),
      .move_right (~J_RIGHT),
      .mode (SW0),
      .smooth_mode (SW1),
      .clk (clk_50),
      .rst_n (rst_n),
      .x (x),
      .y (y),
      .capture_x (capture_x),
      .capture_y (capture_y),
      .draw_box (drawBox),
      .in_box (in_box),
      .template_in_box (template_in_box),
      .template_start(template_start),
      .template_top(template_top),
      .template_left(template_left),
      .max_x(max_x),
      .max_y(max_y),
      .max_ready(max_ready),
      .tracking_mode(capture_state),
      .left(left),
      .right(right),
      .top(top),
      .bottom(bottom),
      .c_x(c_x),
      .c_y(c_y)
    );

    assign capture_data_grayscale = (capture_data[11:8] + capture_data[7:4] + capture_data[3:0])/3;
    
    assign capture_data_template = capture_data_grayscale;

    assign frame_addr = y*`VGA_WIDTH + x;
    
    assign capture_x = capture_addr%`VGA_WIDTH;
    assign capture_y = (capture_addr - capture_x)/`VGA_WIDTH;


    assign capture_static = capture_we && capture_static_we;

    assign LD1 = ~capture_state;
    assign LD3 = ~capture_static_we;
    assign LD4 = ~sobel_we;

    always_comb begin
        if (SW2) begin
            if (template_in_box)
                frame_pixel_display = template_reg[y-template_top][x-template_left];
            else frame_pixel_display = frame_pixel_live;
        end
        else frame_pixel_display = frame_pixel_live;
    end



    always_ff @(posedge clk) begin
        if(~rst_n) begin
            reg_button_press <= 0;
        end else begin
            reg_button_press <= J_BUTTON;
        end
    end

    assign button_pulse = ~reg_button_press &&  J_BUTTON;



    logic pressed;
    logic [$clog2(5000000):0] delay_count;
    always_ff @(posedge clk) begin
        if(~rst_n) begin
            capture_state <= 0; 
            delay_count <= 1;
            pressed <= 0;
        end else if(button_pulse && !pressed) begin
            pressed <= 1;
            capture_state <= ~capture_state;
        end else if(pressed) begin
            delay_count <= delay_count + 1;
            if (delay_count == 0) begin
                pressed <= 0;
            end
        end
    end



  trigger_write_en static_bram_we(.clk(clk),
                                    .rst_n(rst_n),
                                    .sobel_we(~max_ready),
                                    .capture_addr(capture_addr),
                                    .capture_static_we(capture_static_we));


    template_capture record_template(
                                    .clk(clk),
                                    .rst_n(rst_n),
                                    .template_in_box(template_in_box),
                                    .capture_switch(capture_state),
                                    .capture_data_template(frame_pixel_live),
                                    .template_rdy(template_rdy),
                                    .template_reg(template_reg),
                                    .template_start(template_start));

    correlator cor(
                .clk(clk_50),
                .rst_n(rst_n),
                .frame_pixel(frame_pixel_static),
                .static_bram_rdy(~capture_static_we),
                .template_reg(template_reg),
                .left(left),
                .right(right),
                .top(top),
                .bottom(bottom),
                .tracking_mode(capture_state),
                .max_ready(max_ready),
                .static_read_address(static_read_address),
                .max_x(max_x),
                .max_y(max_y),
                .c_x(c_x),
                .c_y(c_y)
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
    input logic clk, rst_n, template_in_box,capture_switch, template_start,
    input logic [3:0] capture_data_template,
    output logic template_rdy,
    output logic [`TEMPLATE_WIDTH-1:0][`TEMPLATE_WIDTH-1:0][3:0] template_reg);


    logic capturing_template;
    logic [5:0] template_x,template_y;
    logic everyOther;


    always_ff @(posedge clk) begin
        if(~rst_n) begin
            template_reg <= 0;
            template_x <= 0;
            everyOther <= 0;
            template_y <= 0;
            capturing_template <= 1;
        end else if(template_in_box && everyOther && capturing_template) begin
             if (template_start) begin
                template_x <= 0;
                template_y <= 0;
            end else if ((template_x == `TEMPLATE_WIDTH - 1)) begin
                template_x <= 0;
                if (template_y == `TEMPLATE_WIDTH - 1) 
                    template_y <= 0;
                else 
                    template_y <= template_y + 1;
                
            end else begin
                template_x <= template_x + 1;
            end

            if (template_y <= `TEMPLATE_WIDTH -1)
                template_reg[template_y][template_x] <= capture_data_template;

        end
        everyOther <= ~everyOther;


        if(capture_switch && template_y == `TEMPLATE_WIDTH - 1 && template_x == `TEMPLATE_WIDTH - 1) begin
            capturing_template <= 0;
        end else if(~capture_switch && template_start) begin
            capturing_template <= 1;
        end
    end


    assign template_rdy = ~capturing_template;


endmodule: template_capture

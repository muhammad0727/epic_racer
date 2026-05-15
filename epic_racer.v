`timescale 1ns / 1ps

module epic_racer (
    input wire clk,
    input wire rst,
    output wire hs,
    output wire vs,
    input wire btnR,
    input wire btnL,
    input wire btnD,
    input wire btnU,
    input wire ps2_clk,
    input wire ps2_data,
    output wire [3:0] r,
    output wire [3:0] g,
    output wire [3:0] b,
    // input wire btn_gear_up,
    // input wire btn_gear_down,
    // input wire enc_a,
    // input wire enc_b,
    // input wire pot_gear_in,
    input wire enc_a,
    input wire enc_b,
    input wire vauxp6,
    input wire vauxn6,
    input wire [5:0] gear_btn
);

wire clk65M;

clk_wiz_0 my_clk(
    .clk(clk),
    .clk_65M(clk65M)
);

wire btnR_D, btnL_D, btnD_D, btnU_D;

buttons_debouncer my_buttons_debouncer(
    .clk(clk65M),
    .btnR(btnR),
    .btnL(btnL),
    .btnU(btnU),
    .btnD(btnD),
    .btnR_D(btnR_D),
    .btnL_D(btnL_D),
    .btnU_D(btnU_D),
    .btnD_D(btnD_D)
);

wire [5:0] keyboard_key;
wire [7:0] keyboard_signal;

keyboard my_keyboard(
    .clk(clk65M),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .rst(rst),
    .key(keyboard_key),
    .keyboard_signal(keyboard_signal)
);
 
wire [10:0] vcount, hcount;
wire vsync, vblnk, hsync, hblnk;

xga_timing my_timing (
    .vcount(vcount),
    .vsync(vsync),
    .vblnk(vblnk),
    .hcount(hcount),
    .hsync(hsync),
    .hblnk(hblnk),
    .pclk(clk65M),
    .rst(rst)
);

// Map buttons directly to car control (btnR_D, btnL_D, btnD_D, btnU_D)
// According to car_ctl.v:
// KEY_UP = 4'b0001 (bit 0)
// KEY_DOWN = 4'b0010 (bit 1)
// KEY_LEFT = 4'b0100 (bit 2)
// KEY_RIGHT = 4'b1000 (bit 3)
wire [3:0] car_control = {btnR_D, btnL_D, btnD_D, btnU_D};





wire [10:0] vcount_tcn, hcount_tcn;
wire vsync_tcn, vblnk_tcn, hsync_tcn, hblnk_tcn;
wire [11:0] rgb_tcn;

draw_track draw_track(
    .vcount_in(vcount),
    .hcount_in(hcount),
    .vsync_in(vsync),
    .hsync_in(hsync),
    .vblnk_in(vblnk),
    .hblnk_in(hblnk),
    .pclk(clk65M),
    .rst(rst),
    .visible(1'b1), // Hardcoded visible
    .rgb_in(12'h000), // Base color black
    .rgb_out(rgb_tcn),
    .hcount_out(hcount_tcn),
    .vcount_out(vcount_tcn),
    .vblnk_out(vblnk_tcn),
    .hblnk_out(hblnk_tcn),
    .vsync_out(vsync_tcn),
    .hsync_out(hsync_tcn)
);

wire [1:0] car_rotation;

wire [11:0] nitro_car_data, rapid_car_data;
wire [11:0] nitro_car_address, rapid_car_address;
wire [10:0] car_xpos, car_ypos;
wire [10:0] car_x_start, car_x_end, car_y_start, car_y_end;

car_ctl my_car_ctl(
    .pclk(clk65M),
    .rst(rst),
    .key(car_control),
    .xpos(car_xpos),
    .ypos(car_ypos),
    .move_dir(car_rotation),
    .car_x_start(car_x_start),
    .car_x_end(car_x_end),
    .car_y_start(car_y_start),
    .car_y_end(car_y_end)
);

wire [10:0] vcount_cncr, hcount_cncr;           
wire vsync_cncr, vblnk_cncr, hsync_cncr, hblnk_cncr;
wire [11:0] rgb_cncr;

draw_img #(64, 64, 12) draw_car_nitro(
    .vcount_in(vcount_tcn),
    .hcount_in(hcount_tcn),
    .vsync_in(vsync_tcn),
    .hsync_in(hsync_tcn),
    .vblnk_in(vblnk_tcn),
    .hblnk_in(hblnk_tcn),
    .pclk(clk65M),
    .rst(rst),
    .xpos(car_xpos),
    .ypos(car_ypos),
    .visible(1'b1), // Hardcoded visible
    .rotation(car_rotation),
    .rgb_in(rgb_tcn),
    .rgb_pixel(nitro_car_data),
    .pixel_addr(nitro_car_address),
    .rgb_out(rgb_cncr),
    .vcount_out(vcount_cncr),
    .hcount_out(hcount_cncr),
    .vsync_out(vsync_cncr),
    .hsync_out(hsync_cncr),
    .vblnk_out(vblnk_cncr),
    .hblnk_out(hblnk_cncr)
);

image_rom #(
    .IMG_WIDTH(64),
    .IMG_HEIGHT(64),
    .ADDR_WIDTH(12),
    .IMG_PATH("./images/nitro.data")
) car_nitro_rom (
    .clk(clk65M),
    .address(nitro_car_address),
    .rgb_out(nitro_car_data)
);

wire [10:0] vcount_crrc, hcount_crrc;           
wire vsync_crrc, vblnk_crrc, hsync_crrc, hblnk_crrc;
wire [11:0] rgb_crrc;

draw_img #(64, 64, 12) draw_car_rapid(
    .vcount_in(vcount_cncr),
    .hcount_in(hcount_cncr),
    .vsync_in(vsync_cncr),
    .hsync_in(hsync_cncr),
    .vblnk_in(vblnk_cncr),
    .hblnk_in(hblnk_cncr),
    .pclk(clk65M),
    .rst(rst),
    .xpos(car_xpos),
    .ypos(car_ypos),
    .visible(1'b1),
    .rotation(car_rotation),
    .rgb_in(rgb_cncr),
    .rgb_pixel(rapid_car_data),
    .pixel_addr(rapid_car_address),
    .rgb_out(rgb_crrc),
    .vcount_out(vcount_crrc),
    .hcount_out(hcount_crrc),
    .vsync_out(vsync_crrc),
    .hsync_out(hsync_crrc),
    .vblnk_out(vblnk_crrc),
    .hblnk_out(hblnk_crrc)
);

image_rom #(
    .IMG_WIDTH(64),
    .IMG_HEIGHT(64),
    .ADDR_WIDTH(12),
    .IMG_PATH("./images/rapid.data")
) car_rapid_rom (
    .clk(clk65M),
    .address(rapid_car_address),
    .rgb_out(rapid_car_data)
);

// Map VGA outputs
// The output should be 0 when blanking, otherwise rgb_crrc
assign hs = hsync_crrc;
assign vs = vsync_crrc;
assign {r, g, b} = (hblnk_crrc || vblnk_crrc) ? 12'h000 : rgb_crrc;

endmodule

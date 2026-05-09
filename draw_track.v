`timescale 1ns / 1ps

module draw_track
(
    input wire [10:0] hcount_in,
    input wire hsync_in,
    input wire hblnk_in,
    input wire [10:0] vcount_in,
    input wire vsync_in,
    input wire vblnk_in,
    input wire pclk,
    input wire rst,
    input wire visible,
    input wire [11:0] rgb_in,
    output reg [10:0] hcount_out,
    output reg hsync_out,
    output reg hblnk_out,
    output reg [10:0] vcount_out,
    output reg vsync_out,
    output reg vblnk_out,
    output reg [11:0] rgb_out
);

localparam HORIZON = 240;
localparam CENTER_X = 512;

reg [11:0] rgb_out_nxt;
wire [10:0] vcount_delayed, hcount_delayed;
wire hsync_delayed, vsync_delayed, hblnk_delayed, vblnk_delayed;

integer road_width;
integer road_width_half;

always @(posedge pclk)
    if(rst)
    begin
        hcount_out <= 0;
        hsync_out <= 0;
        hblnk_out <= 0;
        vcount_out <= 0;
        vsync_out <= 0;
        vblnk_out <= 0;
        rgb_out <= 0;
    end
    else
    begin
        hcount_out <= hcount_delayed;
        hsync_out <= hsync_delayed;
        hblnk_out <= hblnk_delayed;
        vcount_out <= vcount_delayed;
        vsync_out <= vsync_delayed;
        vblnk_out <= vblnk_delayed;
        rgb_out <= rgb_out_nxt;
    end

always @*
begin
    rgb_out_nxt = rgb_in; // default passthrough

    if (visible) begin
        if(vcount_in < HORIZON) begin
            rgb_out_nxt = 12'h8CF; // Sky
        end else begin
            // Simple perspective math
            road_width = vcount_in - HORIZON;
            road_width_half = road_width * 2; // Adjust scale to make road wider at bottom

            if ($signed({1'b0, hcount_in}) > (CENTER_X - road_width_half) && $signed({1'b0, hcount_in}) < (CENTER_X + road_width_half)) begin
                if ($signed({1'b0, hcount_in}) > (CENTER_X - 5) && $signed({1'b0, hcount_in}) < (CENTER_X + 5))
                    rgb_out_nxt = 12'hFFF; // Divider
                else
                    rgb_out_nxt = 12'h333; // Road
            end else begin
                rgb_out_nxt = 12'h050; // Grass
            end
        end
    end
end

delay #(11, 2) hcount_delay(
 .clk(pclk),
 .rst(rst),
 .din(hcount_in),
 .dout(hcount_delayed)
);

delay #(11, 2) vcount_delay(
 .clk(pclk),
 .rst(rst),
 .din(vcount_in),
 .dout(vcount_delayed)
);

delay #(1, 2) vsync_delay(
 .clk(pclk),
 .rst(rst),
 .din(vsync_in),
 .dout(vsync_delayed)
);

delay #(1, 2) hsync_delay(
 .clk(pclk),
 .rst(rst),
 .din(hsync_in),
 .dout(hsync_delayed)
);

delay #(1, 2) vblnk_delay(
 .clk(pclk),
 .rst(rst),
 .din(vblnk_in),
 .dout(vblnk_delayed)
);

delay #(1, 2) hblnk_delay(
 .clk(pclk),
 .rst(rst),
 .din(hblnk_in),
 .dout(hblnk_delayed)
);

endmodule

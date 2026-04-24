`timescale 1ns / 1ps

module gear_char_rom(
    input  wire [15:0] char_xy,
    input  wire [3:0]  current_gear,
    output reg  [6:0]  char_code
);

reg [7:0] gear_char;

always@*
begin
    case(current_gear)
        4'd1: gear_char = 7'h31; // '1'
        4'd2: gear_char = 7'h32; // '2'
        4'd3: gear_char = 7'h33; // '3'
        4'd4: gear_char = 7'h34; // '4'
        4'd5: gear_char = 7'h35; // '5'
        default: gear_char = 7'h31; // default to '1'
    endcase
end

always@*
begin
    case(char_xy)
        16'h0000: char_code = 7'h47; // G
        16'h0100: char_code = 7'h45; // E
        16'h0200: char_code = 7'h41; // A
        16'h0300: char_code = 7'h52; // R
        16'h0400: char_code = 7'h3a; // :
        16'h0500: char_code = 7'h00; //
        16'h0600: char_code = gear_char;
        default: char_code = 0;
    endcase
end

endmodule

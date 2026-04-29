// Code written by Alasdair Nicol, Student ID: 1759586
// Based of the decimal_display_driver template file

// No AI was used in writing this file

`timescale 1ns / 1ps

module decimal_display_driver (
    // Decimal values to be displayed (range: 0-99)
    // value0 -> HEX1 (tens) and HEX0 (ones)
    // value1 -> HEX3 (tens) and HEX2 (ones)
    // value2 -> HEX5 (tens) and HEX4 (ones)
    input logic [6:0] value0,
    input logic [6:0] value1,
    input logic [6:0] value2,

    // Blanking controls for each decimal value.
    // When asserted, both digits of the value are blanked.
    input logic blank0,
    input logic blank1,
    input logic blank2,

    // DE1-SoC seven-segment display outputs.
    // Active-low segments: [g,f,e,d,c,b,a]
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [6:0] HEX4,
    output logic [6:0] HEX5
);



endmodule
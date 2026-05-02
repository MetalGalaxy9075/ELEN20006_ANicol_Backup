// Binary to binary coded decimal converter
//  Converts a binary value into two smaller binary values representing
//  the most significant decimal digit, and the lest significant decimal
//  digit for two digit numbers
//
// Ports:
//  bin   [6:0] : Input number (0-99)
//  tens  [3:0] : Tens place value
//  ones  [3:0] : Ones place value
`timescale 1ns / 1ps

module binary_to_bcd (
    input  logic [6:0] bin,
    output logic [3:0] tens,
    output logic [3:0] ones
);

  assign ones = 4'(bin % 7'd10);
  assign tens = 4'((bin - 7'(ones)) / 7'd10);

endmodule

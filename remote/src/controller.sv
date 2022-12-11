`default_nettype none
`timescale 1ns / 1ps

module controller
    ( input wire clk
    , input wire rst
    , input wire data       // Data line from controller
    , output wire latch     // Latch line from controller
    , output wire pulse     // Pulse line from controller
    , output wire axiov     // Valid when we receive all button inputs
    , output wire [7:0] axiod // One-hot vector of buttons {A, B, SEL, START, U, D, L, R}
    );
endmodule // controller


`default_nettype wire

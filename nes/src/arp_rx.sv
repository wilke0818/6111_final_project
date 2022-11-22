`timescale 1ns / 1ps
`default_nettype none


module arp_rx #(parameter N=2) (
    input wire clk,
    input wire rst,
    input wire axiiv,
    input wire [N-1:0] axiid,
    output logic axiov,
    output logic [N-1:0] axiod //Change later once we know what we want out of IP
  );

endmodule

`default_nettype wire

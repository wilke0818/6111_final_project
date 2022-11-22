`timescale 1ns / 1ps
`default_nettype none



module transport_rx #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [N-1:0] axiid,
  input wire [7:0] protocol_in,
  input wire [31:0] src_ip_in,
  input wire [31:0] dst_ip_in,
  input wire [15:0] packet_length_in,
  output logic axiov,
  output logic udp_kill
  );

  logic udp_axiiv, udp_axiov;
  logic [N-1:0] udp_axiid;

  assign udp_axiiv = axiiv && protocol_in == 17;
  assign udp_axiid = axiiv && protocol_in == 17 ? axiid : 0;

  assign axiov = protocol_in == 17 ? udp_axiov : 0; //fill in additional terneries later

  udp_rx #(.N(N)) udp_in(
    .clk(clk),
    .rst(rst),
    .axiiv(udp_axiiv),
    .axiid(udp_axiid),
    .src_ip_in(src_ip_in),
    .dst_ip_in(dst_ip_in),
    .packet_length_in(packet_length_in),
    .axiov(udp_axiov),
    .kill(udp_kill)
  );

endmodule


`default_nettype wire

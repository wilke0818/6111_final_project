`timescale 1ns / 1ps
`default_nettype none

module network_stack #(parameter N=2) (
  input wire clk, //clock @ 25 or 50 mhz
  input wire rst, //btnc (used for reset)
  input wire [N-1:0] eth_rxd,
  input wire eth_crsdv,
  input wire [47:0] mac,
  output logic eth_txen,
  output logic [N-1:0] eth_txd,
  output logic axiov,
  output logic [15:0] axiod
  );

  parameter MY_IP = 32'h12_12_6b_0d;

  //ETHERNET VARIABLES
  logic ethernet_axiod;
  logic [N-1:0] ordered_eth_rxd;
  logic rx_kill, rx_done, ethernet_axiov, ordered_eth_crsdv, prev_rx_done;

  //NETWORK LAYER VARIABLES
  logic network_rx_axiov;
  logic [7:0] network_rx_protocol;
  logic [31:0] network_rx_src_ip, network_rx_dst_ip;
  logic [15:0] network_packet_length;

  //TRANSPORT LAYER VARIABLES
  logic transport_axiov, udp_kill;

  //DATA STORE VARIABLES
  logic data_rx_axiov, read_out;

  ethernet_rx #(.N(N)) ethernet_in(
    .clk(clk),
    .rst(rst),
    .axiid(eth_rxd),
    .axiiv(eth_crsdv),
    .mac(mac),
    .ethertype(ethernet_axiod),
    .axiov(ethernet_axiov),
    .rx_done(rx_done),
    .rx_kill(rx_kill)
  );

  bitorder #(.N(N)) bitmod( //Kinda redundant but helps encapsulate ethernet logic
    .clk(clk),
    .rst(rst),
    .axiid(eth_rxd),
    .axiiv(eth_crsdv),
    .axiod(ordered_eth_rxd),
    .axiov(ordered_eth_crsdv));


  network_rx #(.N(N)) network_in(
    .clk(clk),
    .rst(rst),
    .ethertype_in(ethernet_axiod),
    .axiid(ordered_eth_rxd),
    .axiiv(ethernet_axiov && ordered_eth_crsdv),
    .axiov(network_rx_axiov),
    .src_ip_out(network_rx_src_ip),
    .dst_ip_out(network_rx_dst_ip),
    .ip_protocol_out(network_rx_protocol),
    .packet_length_out(network_packet_length)
  );

  transport_rx #(.N(N)) transport_in(
    .clk(clk),
    .rst(rst),
    .axiid(ordered_eth_rxd),
    .axiiv(ordered_eth_crsdv && network_rx_axiov && network_rx_dst_ip == MY_IP), //maybe remove last condition?
    .protocol_in(network_rx_protocol),
    .src_ip_in(network_rx_src_ip),
    .dst_ip_in(network_rx_dst_ip),
    .packet_length_in(network_packet_length-16'd20),
    .axiov(transport_axiov),
    .udp_kill(udp_kill)
  );
 
  data_store_rx #(.N(N)) data_in(
    .clk(clk),
    .rst(rst),
    .axiid(ordered_eth_rxd),
    .axiiv(transport_axiov && ordered_eth_crsdv),
    .read_request(read_out),
    .axiov(axiov),
    .axiod(axiod)
  );

  always_ff @(posedge clk) begin
    if (rst) begin
      read_out <= 0;
    end else begin
      if (~prev_rx_done && rx_done) begin
        read_out <= ~udp_kill && ~rx_kill;
      end
      prev_rx_done <= rx_done;
    end
  end

endmodule

`default_nettype wire

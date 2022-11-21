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
  output logic [15:0] axiod,
  input wire [31:0] dst_ip_in,
  input wire [7:0] transport_protocol_in,
  input wire [15:0] ethertype_in,
  input wire [15:0] udp_src_port_in,
  input wire [15:0] udp_dst_port_in
  );

  parameter MY_IP = 32'h12_12_6b_0d;

//begin receiver

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
//end receiver

//begin transmitter

  parameter TX_ETHERNET = 0;
  parameter TX_NETWORK = 1;
  parameter TX_TRANSPORT = 2;
  parameter TX_DATA = 3;
  parameter TX_ETHERNET_CKSUM = 4;

  logic [2:0] tx_state;
  logic [N-1:0] ethernet_axiod_tx, network_axiod_tx, transport_axiod_tx, data_axiod_tx, axiod_mux_tx, eth_cksum_axiod_tx;
  logic ethernet_axi_last_tx, network_axi_last_tx, transport_axi_last_tx, data_axi_last_tx;
  logic ethernet_axiiv_tx, network_axiiv_tx, transport_axiiv_tx, data_axiiv_tx, axiiv_mux_tx;
  logic [N-1:0] axiid_mux_tx;
  logic ethernet_axiov_tx, network_axiov_tx, transport_axiov_tx, data_axiov_tx, axiov_mux_tx;

  logic [15:0] data_length, data_cksum;

  logic [$clog2(32/N)-1:0] cksum_count_tx;

  assign eth_txd = tx_state != TX_ETHERNET_CKSUM ? axiod_mux_tx : eth_cksum_axiod_tx;
  

  //TODO data store that then triggers the start of transmitting

  //TODO connect Miles' ethernet or write my own

  network_tx #(.N(N)) (
    .clk(clk),
    .rst(rst),
    .axiiv(network_axiiv_tx),
    .ethertype_in(ethertype_in),
    .axiov(network_axiov_tx),
    .axiod(network_axiod_tx),
    .src_ip_in(MY_IP),
    .dst_ip_in(dst_ip_in),
    .ip_protocol_in(transport_protocol_in),
    .data_length_in(data_length),
    .axi_last(network_axi_last_tx)
  );

  transport_tx #(.N(N)) transport_out (
    .clk(clk),
    .rst(rst),
    .axiiv(transport_axiiv_tx),
    .protocol_in(transport_protocol_in),
    .src_ip_in(MY_IP),
    .dst_ip_in(dst_ip_in),
    .data_length_in(data_length),
    .data_checksum_in(data_cksum),
    .udp_src_port_in(udp_src_port_in),
    .udp_dst_port_in(udp_dst_port_in),
    .axiov(transport_axiov_tx),
    .axiod(transport_axiod_tx),
    .axi_last(transport_axi_last_tx)
  );

  //TODO data store again but now read from it

  //TODO ethernet cksum
  crc32 check_sum(
    .clk(clk),
    .rst(rst),
    .axiiv(axiov_mux_tx), //drops when state changes to cksum
    .axiid(axiod_mux_tx), //takes in the reversed bitorder
    .axiov(), //always 1
    .axiod(eth_cksum_axiod_tx));

  bitorder #(.N(N)) bit_out( 
    .clk(clk),
    .rst(rst),
    .axiid(axiid_mux_tx),
    .axiiv(axiiv_mux_tx),
    .axiod(axiod_mux_tx),
    .axiov(axiov_mux_tx));

  always_ff @(posedge clk) begin
    if (rst) begin
       ethernet_axiiv_tx <= 0;
       network_axiiv_tx <= 0;
       transport_axiiv_tx <= 0;
       data_axiiv_tx <= 0;
       cksum_count_tx <= 0;
       axiiv_mux_tx <= 0;
       
       tx_state <= TX_ETHERNET;
    end else begin
      if (eth_txen) begin
        axiiv_mux_tx <= tx_state != TX_ETHERNET_CKSUM;
        case(tx_state)
          TX_ETHERNET : begin
            if (ethernet_axi_last_tx) begin
              tx_state <= TX_NETWORK;
              ethernet_axiiv_tx <= 1'b0;
              network_axiiv_tx <= 1'b1;
              axiid_mux_tx <= network_axiod_tx;
            end else begin
              axiid_mux_tx <= ethernet_axiod_tx;
              ethernet_axiiv_tx <= 1'b1;
            end
          end
          TX_NETWORK : begin
            if (network_axi_last_tx) begin
              tx_state <= TX_TRANSPORT;
              network_axiiv_tx <= 1'b0;
              transport_axiiv_tx <= 1'b1;
              axiid_mux_tx <= transport_axiod_tx;
            end else begin
              axiid_mux_tx <= network_axiod_tx;
              network_axiiv_tx <= 1'b1;
            end
          end
          TX_TRANSPORT : begin
            if (transport_axi_last_tx) begin
              tx_state <= TX_DATA;
              transport_axiiv_tx <= 1'b0;
              data_axiiv_tx <= 1'b1;
              axiid_mux_tx <= data_axiod_tx;
            end else begin
              axiid_mux_tx <= transport_axiod_tx;
              transport_axiiv_tx <= 1'b1;
            end
          end
          TX_DATA : begin
            if (data_axi_last_tx) begin
              tx_state <= TX_ETHERNET_CKSUM;
              data_axiiv_tx <= 1'b0;
              
            end else begin
              data_axiiv_tx <= 1'b1;
              axiid_mux_tx <= data_axiod_tx;
            end
          end
          TX_ETHERNET_CKSUM : begin
            //set eth_txen to 0 at the end
            if (cksum_count_tx < 32/N-1) begin
              cksum_count_tx <= cksum_count_tx + 1;
            end else begin
              eth_txen <= 0;
              //later add interpacket gap bs
            end
          end
        endcase
      end
    end
  end

//end transmitter
endmodule

`default_nettype wire

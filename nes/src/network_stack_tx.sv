`timescale 1ns / 1ps
`default_nettype none

module network_stack_tx #(parameter N=2, parameter DATA_SIZE=16) (
  input wire clk, //clock @ 25 or 50 mhz
  input wire rst, //btnc (used for reset)
  input wire [47:0] mac,
  input wire [47:0] dst_mac,
  input wire axiiv,
  input wire [DATA_SIZE-1:0] axiid,
  output logic eth_txen,
  output logic [N-1:0] eth_txd,
  input wire [31:0] dst_ip_in,
  input wire [7:0] transport_protocol_in,
  input wire [15:0] ethertype_in,
  input wire [15:0] udp_src_port_in,
  input wire [15:0] udp_dst_port_in
  );

  parameter MY_IP = 32'h12_12_6b_0d;
  logic [2:0] byte_count, bit_count;  

//begin transmitter
  
  parameter TX_ETHERNET = 0;
  parameter TX_NETWORK = 1;
  parameter TX_TRANSPORT = 2;
  parameter TX_DATA = 3;
  parameter TX_ETHERNET_CKSUM = 4;
  parameter TX_INTERPACKET_GAP = 5;

  parameter CKSUM_VALID_INPUTS = 8/N;

  logic [2:0] tx_state; 

  //data store variables
  logic data_axiiv_tx, data_axiov_tx, data_axi_last;
  logic [N-1:0] data_axiod_tx;
  logic [15:0] data_length, data_cksum;

  //ether variables
  logic ether_axiiv_tx, ether_axiov_tx, ether_axio_cksum, ether_axi_last;
  logic [N-1:0] ether_axiod_tx;
  

  //network variables
  logic network_axiiv_tx, network_axiov_tx, network_axi_last;
  logic [N-1:0] network_axiod_tx;

  //transport varaiables
  logic transport_axiiv_tx, transport_axiov_tx, transport_axi_last;
  logic [N-1:0] transport_axiod_tx;

  //cksum variables
  logic cksum_axiiv_tx, cksum_axiov_tx;
  logic [N-1:0] cksum_axiid_tx;
  logic [31:0] cksum_axiod_tx;
  logic [4:0] cksum_count_tx;
  logic old_txen;

  //bit order variables
  logic bit_axiiv_tx, bit_axiov_tx;
  logic [N-1:0] bit_axiid_tx, bit_axiod_tx;
  logic [2:0] bit_axio_cksum_count;

  //other variables
  logic prev_axiiv;
  logic [5:0] gap_count;
  

  assign eth_txen = bit_axiov_tx | cksum_axiov_tx;
  assign transport_axiiv_tx = rst ? 0 : tx_state == TX_TRANSPORT || network_axi_last;
  assign network_axiiv_tx = rst ? 0 : tx_state == TX_NETWORK || ether_axi_last;
  assign data_axiiv_tx = rst ? 0 : tx_state == TX_DATA || transport_axi_last;



  data_store_tx #(.N(N), .DATA_SIZE(DATA_SIZE)) data_out (
    .clk(clk),
    .rst(rst),
    .axiiv(axiiv), //feed in valid and data from top_level to transmit
    .axiid(axiid),
    .read_request(data_axiiv_tx), //begin reading out data 
    .axiov(data_axiov_tx),
    .axiod(data_axiod_tx),
    .data_sum(data_cksum),
    .data_length(data_length),
    .axi_last(data_axi_last)
  );


  ether_tx #(.N(N)) ether_out (
    .clk(clk),
    .rst(rst),
    .my_mac(mac),
    .dest_mac(dst_mac),
    .etype(ethertype_in),
    .axiiv(ether_axiiv_tx),
    .axiov(ether_axiov_tx),
    .axiod(ether_axiod_tx),
    .axio_cksum(ether_axio_cksum),
    .axi_last(ether_axi_last)
  );

  network_tx #(.N(N)) network_out (
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
    .axi_last(network_axi_last)
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
    .axi_last(transport_axi_last)
  );


  //TODO ethernet cksum
  crc32 check_sum(
    .clk(clk),
    .rst(rst || (old_txen && ~eth_txen)),
    .axiiv(cksum_axiiv_tx), //drops when state changes to cksum
    .axiid(cksum_axiid_tx), 
    .axiov(), //always 1
    .axiod(cksum_axiod_tx));

  bitorder #(.N(N)) bit_out( 
    .clk(clk),
    .rst(rst),
    .axiid(bit_axiid_tx),
    .axiiv(bit_axiiv_tx),
    .axiod(bit_axiod_tx),
    .axiov(bit_axiov_tx));

  assign cksum_axiid_tx = bit_axiod_tx;
  assign cksum_axiiv_tx = tx_state != TX_ETHERNET ? bit_axiov_tx : ether_axio_cksum && bit_axio_cksum_count >= CKSUM_VALID_INPUTS  ? 1'b1 : 0;

  always_comb begin
    if (rst) begin 
      ether_axiiv_tx = 0;
      bit_axiiv_tx = 0;
      eth_txd = 0;
      bit_axiid_tx = 0;
     
    end else begin
//      if (prev_axiiv && ~axiiv) begin
  //      ether_axiiv_tx = 1'b1;
    //  end else begin
      //  ether_axiiv_tx = ether_axiiv_tx;
     // end


      case (tx_state)
        TX_ETHERNET : begin
          ether_axiiv_tx = prev_axiiv && ~axiiv ? 1'b1 : ether_axiov_tx;
          eth_txd = bit_axiod_tx;
          bit_axiid_tx = ether_axi_last ? network_axiod_tx : ether_axiod_tx;
          bit_axiiv_tx = ether_axi_last ? network_axiiv_tx : ether_axiov_tx;
        end
        TX_NETWORK : begin
          ether_axiiv_tx = 0;
          eth_txd = bit_axiod_tx;
          bit_axiid_tx = network_axiod_tx;
          bit_axiiv_tx = 1'b1;
        end
        TX_TRANSPORT : begin
          ether_axiiv_tx = 0;
          eth_txd = bit_axiod_tx;
          bit_axiid_tx = transport_axiod_tx;
          bit_axiiv_tx = 1'b1;
        end
        TX_DATA : begin
          ether_axiiv_tx = 0;
          eth_txd = bit_axiod_tx;
          bit_axiid_tx = data_axiod_tx;
          bit_axiiv_tx = data_axiov_tx;
        end
        TX_ETHERNET_CKSUM : begin
          ether_axiiv_tx = 0;
        //  bit_axiid_tx = cksum_axiod_tx[31 - N*cksum_count_tx -: N];
          if (~bit_axiov_tx) begin
            eth_txd = {cksum_axiod_tx[31 - N*cksum_count_tx-1], cksum_axiod_tx[31 - N*cksum_count_tx]};
//            eth_txd = {cksum_axiod_tx[32 - 8*byte_count + N*bit_count],cksum_axiod_tx[32 - 8*byte_count + N*bit_count + 1]};
//25:24,...,31:30,17:16
          end else begin
            eth_txd = bit_axiod_tx;
          end
          bit_axiiv_tx = 0;
          bit_axiid_tx = 0;
        end
        default : begin
          ether_axiiv_tx = 0;
          eth_txd = 0;
          bit_axiid_tx = 0;
          bit_axiiv_tx = 0;
        end
      endcase
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      prev_axiiv <= 0;
      tx_state <= 0;
      bit_axio_cksum_count <= 0;
      cksum_count_tx <= 0;
      cksum_axiov_tx <= 0;
      gap_count <= 0;
      bit_count <= 0;
      byte_count <= 1;
      old_txen <= 0;
    end else begin
      prev_axiiv <= axiiv;
      old_txen <= eth_txen;
      case (tx_state)
        TX_ETHERNET : begin
          if (ether_axi_last) begin
            tx_state <= TX_NETWORK;
         //   network_axiiv_tx <= 1'b1;
          end
          if (ether_axio_cksum) begin
            if (bit_axio_cksum_count < CKSUM_VALID_INPUTS ) begin
              bit_axio_cksum_count <= bit_axio_cksum_count + 1;
            end //else begin
              //cksum_axiid_tx <= bit_axiod_tx;
              //cksum_axiiv_tx <= 1'b1;
           // end
          end else begin
            //cksum_axiid_tx <= 0;
            //cksum_axiiv_tx <= 0;
            bit_axio_cksum_count <= 0;
          end
        end
        TX_NETWORK : begin
          if (network_axi_last) begin
            tx_state <= TX_TRANSPORT;
       //     transport_axiiv_tx <= 1'b1;
          end
        end
        TX_TRANSPORT : begin
          if (transport_axi_last) begin
            tx_state <= TX_DATA;
       //     data_axiiv_tx <= 1'b1;
          end
        end
        TX_DATA : begin
          if (data_axi_last) begin
            tx_state <= TX_ETHERNET_CKSUM;
            //cksum_axiid_tx <= 0;
//            //cksum_axiiv_tx <= 0;
            cksum_axiov_tx <= 1'b1;
          end
        end
        TX_ETHERNET_CKSUM : begin
          if (~bit_axiov_tx) begin
            if (cksum_count_tx < 32/N-1) begin
              cksum_axiov_tx <= 1'b1;
              cksum_count_tx <= cksum_count_tx + 1;
            end else begin
              //bit_axiiv_tx <= 0;
              cksum_axiov_tx <= 0;
              cksum_count_tx <= 0;
              gap_count <= 0;
              tx_state <= TX_INTERPACKET_GAP;
            end
          //  if (bit_count < 8/N-1) begin
          //    bit_count <= bit_count + 1;
          //  end else begin
          //    bit_count <= 0;
          //    cksum_axiov_tx <= byte_count != 4 ? 1 : 0;
          //    byte_count <= byte_count != 4 ? byte_count + 1 : 0;
          //    tx_state <= byte_count == 4 ? TX_INTERPACKET_GAP : tx_state;
          //  end
          end
        end
        TX_INTERPACKET_GAP : begin
          if (gap_count < 96/N-1) begin
            gap_count <= gap_count + 1;
          end else begin
            tx_state <= TX_ETHERNET;
          end
        end
      endcase

    end
  end

//end transmitter
endmodule

`default_nettype wire

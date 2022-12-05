`timescale 1ns / 1ps
`default_nettype none

module top_level(
  input wire clk, //clock @ 100 mhz
  input wire btnc, //btnc (used for reset)
  input wire btnl,
  output logic eth_refclk,
  input wire [1:0] eth_rxd,
  output logic eth_rstn,
  input wire eth_crsdv,
  output logic [1:0] eth_txd,
  output logic eth_txen
//  output logic [15:0] led, //just here for the funs

//  output logic [7:0] an,
//  output logic ca,cb,cc,cd,ce,cf,cg

  );

  parameter MY_MAC = 48'h42_04_20_42_04_20;
  parameter N = $bits(eth_rxd);
  parameter DATA_SIZE = 16;

  /* have btnd control system reset */
  logic sys_rst;
  assign sys_rst = btnc;
  assign eth_rstn = ~sys_rst;

  logic [DATA_SIZE-1:0] test_data_in;
  logic [2:0] test_count;
  logic test_data_valid_in, send_button, old_send_button;
  
  divider ether_clk( 
    .clk(clk),
    .ethclk(eth_refclk)
  );

  debouncer btnc_db(.clk_in(eth_refclk),
                  .rst_in(sys_rst),
                  .dirty_in(btnl),
                  .clean_out(send_button));

  network_stack #(.N(N), .DATA_SIZE(DATA_SIZE)) da_net(
    .clk(eth_refclk),
    .rst(sys_rst),
    .eth_rxd(eth_rxd),
    .eth_crsdv(eth_crsdv),
    .mac(MY_MAC),
    .dst_mac(48'hFF_FF_FF_FF_FF_FF),
    .axiiv(test_data_valid_in),
    .axiid(test_data_in),
    .dst_ip_in(32'hFF_FF_FF_FF),
    .transport_protocol_in(8'h11),
    .ethertype_in(16'h0800),
    .udp_src_port_in(16'd42069),
    .udp_dst_port_in(16'd42069),
    .eth_txd(eth_txd),
    .eth_txen(eth_txen)
  );

  always_ff @(posedge eth_refclk) begin
    if (sys_rst) begin
      old_send_button <= 0;
      test_data_valid_in <= 0;
      test_data_in <= 0;
      test_count <= 0;
    end else begin
      old_send_button <= send_button;
      if (~old_send_button && send_button) begin
        test_data_valid_in <= 1'b1;
        test_data_in <= 16'hABCD;
        test_count <= 1;
      end

      if (test_count == 1) begin
        test_count <= 2;
        test_data_in <= 16'h6969;
      end else if (test_count == 2) begin
        test_count <= 3;
        test_data_in <= 16'hFFFF;
      end else if (test_count == 3) begin
        test_count <= 4;
        test_data_in <= 16'h0420;
      end else if (test_count == 4) begin
        test_count <= 5;
        test_data_in <= 16'hABCD;
      end else if (test_count == 5) begin
        test_count <= 6;
        test_data_in <= 16'h6969;
      end else if (test_count == 6) begin
        test_count <= 7;
        test_data_in <= 16'hFFFF;
      end else if (test_count == 7) begin
        test_count <= 0;
        test_data_valid_in <= 0;
      end
    end
  end

endmodule
`default_nettype wire

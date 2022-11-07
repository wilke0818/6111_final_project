`timescale 1ns / 1ps
`default_nettype none


module ethernet_tx #(parameter N=2) (
  input wire clk,             // clock @ 25 or 50 mhz
  input wire rst,             // btnc (used for reset)
  input wire [N-1:0] axiid,   // AXI Input Data
  input wire axiiv,           // AXI Input Valid
  input wire [47:0] my_mac,   // MAC address of this FPGA
  input wire [47:0] dest_mac, // MAC address of destination device
  input wire [15:0] etype,    // Ethernet type
  output logic axiov,         // Transmitting valid data
  output logic [N-1:0] axiod, // Data being transmitted
  );

  // NOTE: Transmits in MSB/MSB order, so must route through bitorder before sending

  parameter PRE_COUNT = (64/N)-1;

  enum state = {IDLE, SEND_HEADER, SEND_DATA, SEND_CRC};

  logic axii_cksum;

  logic axiiv_ether;
  logic [N-1:0] axiid_ether;
  logic axiov_ether;
  logic [N-1:0] axiod_ether;
  logic axiiv_data;
  logic axiov_data;
  logic [N-1:0] axiod_data;

  logic [7:0] cksum_count;

  // FIXME: Currently beings transmission as soon as axiiv is asserted
  //        May need to change to something like axi_last in the future


  ether_tx #(.N(N)) ether_tx_m(
    .clk(clk),
    .rst(rst),
    .axiiv(axiiv_ether),
    .axiid(axiid_ether),
    .my_mac(my_mac),
    .dest_mac(dest_mac),
    .etype(etype),
    .axiov(axiov_ether),
    .axiod(axiod_ether),
    .axio_cksum(axii_cksum)
  );

  // TODO: DATA MODULE (NEED TO WAIT FOR IP MODULE TO BE WRITTEN)

  if (N==4) begin
    crc32_4bit check_sum_4(
      .clk(clk),
      .rst(rst),
      .crc_en(axii_cksum),
      .data_in(axiod_ether | axiod_data),
      .crc_out_en(check_valid_out_4),
      .crc_out(check_sum_out_2)
    );
    
  end else begin
    crc32 check_sum_2(
      .clk(clk),
      .rst(rst),
      .axiiv(axii_cksum),
      .axiid(axiod_ether | axiod_data),
      .axiov(check_valid_out_2),
      .axiod(check_sum_out_2)
    );
  end

  // FIXME: May be best to turn axiod mux into a comb block
  always_ff @(posedge clk) begin
    case (state)
      IDLE: begin
        axiov <= 0;
        axiod <= 0;
        if (axiiv) begin
          axiiv_ether <= 1;
          state <= SEND_HEADER;
        end
      end
      SEND_HEADER: begin
        axiod <= axiod_ether;
        if (~axiov_ether) begin
          axiiv_ether <= 0;
          state <= SEND_DATA;
        end
      end
      SEND_DATA: begin
        axiod <= axiod_data;
        if (~axiov_data) begin
          axiiv_data <= 0;
          axii_cksum <= 0;
          state <= SEND_CRC;
        end
      end
      SEND_CRC: begin
        if (N==2)begin
          axiod <= check_sum_out_2[cksum_count:cksum_count-1];
          cksum_count <= cksum_count - 2;
        end else begin
          axiod <= check_sum_out_4[cksum_count:cksum_count-3];
          cksum_count <= cksum_count - 4;
        end
        if (cksum_count == 0) begin
          axiov <= 0;
          state <= IDLE;
        end
      end
    endcase
  end


endmodule
`default_nettype wire

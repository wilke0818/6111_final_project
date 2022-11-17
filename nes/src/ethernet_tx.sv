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
  output logic [N-1:0] axiod // Data being transmitted
  );

  // NOTE: Transmits in MSB/MSB order, so must route through bitorder before sending

  parameter PRE_COUNT = (64/N)-1;

  enum {IDLE, SEND_HEADER, SEND_DATA, SEND_CRC} state;

  logic axii_cksum;
  logic rst_cksum;
  logic old_axiov = 0;
  logic old_axiiv = 0;

  logic axiiv_ether;
  logic [N-1:0] axiid_ether;
  logic axiov_ether;
  logic [N-1:0] axiod_ether;
  logic axiiv_data;
  logic axiov_data;
  logic [N-1:0] axiod_data;

  logic check_valid_out_2;
  logic [31:0] check_sum_out_2;
  logic check_valid_out_4;
  logic [31:0] check_sum_out_4;

  logic [N-1:0] axiid_cksum;
  logic [7:0] cksum_count;
  logic axiov_raw;
  logic [N-1:0] axiod_raw;
  logic axiov_flipped;
  logic [N-1:0] axiod_flipped;
  logic [N-1:0] axiod_crc;
  logic axiov_crc;

  // assign axiov = axiov_flipped;
  // assign axiod = axiod_flipped;

  logic axii_cksum_header;
  logic axii_cksum_data;

  logic [15:0] test_counter;
  parameter TEST_BYTE = 8'b1110_1011;

  // FIXME: Currently beings transmission as soon as axiiv is asserted
  //        May need to change to something like axi_last in the future
  
  /* 
  ila i(.clk(clk),
        .probe0(axiov),
        .probe1(axiod));
      */


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
    .axio_cksum(axii_cksum_header)
  );

  bitorder #(.N(N)) bitorder_m(
    .clk(clk),
    .rst(rst),
    .axiiv(axiov_raw),
    .axiid(axiod_raw),
    .axiov(axiov_flipped),
    .axiod(axiod_flipped)
  );

  // TODO: DATA MODULE (NEED TO WAIT FOR IP MODULE TO BE WRITTEN)

  // TODO: DO NOT need to feed checksum through bitorder as well
  if (N==4) begin
    crc32_4bit check_sum_4(
      .clk(clk),
      .rst(rst_cksum | rst),
      .crc_en(axii_cksum_header | axii_cksum_data),
      .data_in(axiid_cksum),
      .crc_out_en(check_valid_out_4),
      .crc_out(check_sum_out_4)
    );
    
  end else begin
    crc32 check_sum_2(
      .clk(clk),
      .rst(rst_cksum | rst),
      .axiiv(axii_cksum_header | axii_cksum_data),
      .axiid(axiid_cksum),
      .axiov(check_valid_out_2),
      .axiod(check_sum_out_2)
    );
  end

  always_comb begin
    if (state != SEND_CRC)begin
      axiov = axiov_flipped;
      axiod = axiod_flipped;
    end
    if (state == IDLE)begin
      axiod_raw = 0;
      axiid_cksum = 0;
    end else if (state == SEND_HEADER)begin
      axiid_cksum = axiod_ether;
      axiod_raw = axiod_ether;
    end else if (state == SEND_DATA)begin
      axiid_cksum = axiod_data;
      axiod_raw = axiod_data;
    end else if (state == SEND_CRC)begin
      axiod_raw = 0;
      axiid_cksum = 0;
      axiov_crc = 1;
      if (N==2)begin
        axiod_crc = check_sum_out_2[cksum_count -: 2];
      end else begin
        axiod_crc = check_sum_out_4[cksum_count -: 4];
      end
      axiov = axiov_crc;
      axiod = axiod_crc;
    end else begin
      axiod_raw = 0;
      axiid_cksum = 0;
    end
  end

  // always_comb begin
  //      if ((state == SEND_HEADER) && old_axiov && ~axiov_ether)begin
  //     axii_cksum_data = 1;
  //     state = SEND_DATA;
  //     axiov_data = 1;
  //     axiod_data = TEST_BYTE[7:4];
    //end
  // end

  // FIXME: May be best to turn axiod mux into a comb block
  always_ff @(posedge clk) begin
    case (state)
      IDLE: begin
        old_axiiv <= axiiv;
        axiov_raw <= 0;
        // axiod_raw <= 0;
        rst_cksum <= 1;
        cksum_count <= 31;
        test_counter <= 0;
        axii_cksum_data <= 0;
        old_axiov <= 0;
        // axii_cksum <= 0;
        if (~old_axiiv && axiiv) begin
          axiiv_ether <= 1;
          state <= SEND_HEADER;
        end
      end
      SEND_HEADER: begin
        rst_cksum <= 0;
        // axiod_raw <= axiod_ether;
        if (axiov_ether) begin
          axiov_raw <= 1;
        end
        old_axiov <= axiov_ether;
        axiiv_ether <= 0;
        if (old_axiov && ~axiov_ether) begin
          // axii_cksum <= 1;    // FIXME: REMOVE THIS ONCE DATA MODULE IS WRITTEN
          axii_cksum_data <= 1;
          axiov_data <= 1;
          axiod_data <= TEST_BYTE[7:4];
          state <= SEND_DATA;
        end
      end
      SEND_DATA: begin
        // axiod_raw <= axiod_data;
        test_counter <= test_counter + 1;
        if (test_counter == 30)
          axiod_data <= 4'b0011;
        if (test_counter == 31)begin
          // axiod_data <= TEST_BYTE[3:0];
          // axiov_raw <= 0;
          axiov_data <= 0;
          axii_cksum_data <= 0;
          cksum_count <= 31;
          test_counter <= 33;
          // state <= SEND_CRC;
        end
        if (~axiov_data) begin
          test_counter <= test_counter + 1;
          if (test_counter == 34)begin
            axiov_raw <= 0;
            axii_cksum_data <= 0;
            state <= SEND_CRC; 
          end
        end
      end
      SEND_CRC: begin
        if (cksum_count != 0) begin
            test_counter <= 1;
            cksum_count = cksum_count - N;
        end
        if (cksum_count == N-1) begin
          test_counter <= test_counter -1;
        end
        if (test_counter == 0)begin
          axiov_crc <= 0;
          state <= IDLE;
        end
      end
    endcase
  end


endmodule
`default_nettype wire

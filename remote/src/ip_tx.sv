`timescale 1ns / 1ps
`default_nettype none

module internet_protocol_tx #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [15:0] data_length_in,
  input wire [15:0] transport_header_length_in,
  input wire [31:0] src_ip_in,
  input wire [31:0] dst_ip_in,
  input wire [7:0] protocol_in,
  output logic axiov,
  output logic [N-1:0] axiod,
  output logic axi_last
  );

  parameter V_IHL_DSCP_ECN = 16'b0100_0101_100000_00;
  parameter FLAG_FRAG_TTL = 24'b010_0000000000000_01000000;

  parameter FIRST_TWO_BYTES = 0;
  parameter LENGTH = 1;
  parameter ID = 2;
  parameter PRE_PROTOCOL = 3;
  parameter PROTOCOL = 4;
  parameter CKSUM = 5;
  parameter SRC_IP = 6;
  parameter DST_IP = 7;
  parameter NON_IP = 8;
  
  logic [3:0] state;

  logic [$clog2(32/N)-1:0] count;
  logic [15:0] ip_checksum, ip_length;
  logic [15:0] id;

  logic rst_now;

  logic [16:0] src_sum, dst_sum, init_data, ip_sum;
  logic init_valid, cksum_valid_in;
  logic [1:0] init_state;

  assign ip_length = data_length_in + transport_header_length_in + 16'd20;
  //assign axiov = ~rst ?  state != NON_IP && axiiv : 0;
  
  bland_cksum #(.N(N)) udp_cksum (
    .clk(clk),
    .rst(rst || rst_now),
    .axiiv(axiov),
    .axiid(cksum_valid_in ? axiod : 0),
    .init_valid(init_valid),
    .init_data(init_data[15:0] + init_data[16]),
    .axiod(ip_checksum)
  );

  //Minimize combinational chain by adding over a few cycles
  always_ff @(posedge clk) begin
    if (rst) begin
      init_valid <= 0;
      init_data <= 0;
      init_state <= 0;
      src_sum <= 0;
      dst_sum <= 0;
    end else begin
      if (axiiv) begin
        if (init_state == 0) begin
          init_data <= {1'b0, 8'h40, protocol_in};
          src_sum <= src_ip_in[31:16] + src_ip_in[15:0];
          dst_sum <= dst_ip_in[31:16] + dst_ip_in[15:0];
          init_state <= 2'b01;
        end else if (init_state == 1) begin
          ip_sum <= src_sum[15:0]+src_sum[16]+dst_sum[15:0]+dst_sum[16];
          init_state <= 2'b10;
        end else if (init_state == 2) begin
          init_data <= ip_sum[15:0]+ip_sum[16]+init_data[15:0]+init_data[16];
          init_state <= 2'b11;
          init_valid <= 1'b1;
        end
      end
    end
  end

  //assign cksum_valid_in = rst ? 0 : axiiv && (state < PRE_PROTOCOL || (state == PRE_PROTOCOL && count <= 16/N)) ? 1'b1 : 0;

  always_ff @(posedge clk) begin
    if (rst) begin
      state <= 0;
      axiov <= 0;
      axiod <= 0;
      id <= 0;
      cksum_valid_in <= 0;
      rst_now <= 0;
    end else begin
      if (axiiv) begin
      //  axiov <= 1'b1;
        case (state)
          FIRST_TWO_BYTES : begin
            cksum_valid_in <= 1'b1;
            axiov <= 1'b1;
            axiod <= V_IHL_DSCP_ECN[15-N*count -: N];
            count <= count == 16/N-1 ? 0 : count + 1;
            state <= count == 16/N-1 ? LENGTH : state;
          end
          LENGTH : begin
            axiod <= ip_length[15-N*count -: N];
            count <= count == 16/N-1 ? 0 : count + 1;
            state <= count == 16/N-1 ? ID : state;
          end
          ID : begin
            axiod <= id[15-N*count -: N];
            count <= count == 16/N-1 ? 0 : count + 1;
            id <= count == 16/N-1 ? id+1 : id;
            state <= count == 16/N-1 ? PRE_PROTOCOL : state;
          end
          PRE_PROTOCOL : begin
            axiod <= FLAG_FRAG_TTL[23-N*count -: N];
            count <= count == 24/N-1 ? 0 : count + 1;
            state <= count == 24/N-1 ? PROTOCOL : state;
            cksum_valid_in <= count == 16/N-1 ? 0 : cksum_valid_in;
          end
          PROTOCOL : begin
            axiod <= protocol_in[7-N*count -: N];
            count <= count == 8/N-1 ? 0 : count + 1;
            state <= count == 8/N-1 ? CKSUM : state;
          end
          CKSUM : begin
            axiod <= ip_checksum[15-N*count -: N];
            count <= count == 16/N-1 ? 0 : count + 1;
            state <= count == 16/N-1 ? SRC_IP : state;
          end
          SRC_IP : begin
            
            axiod <= src_ip_in[31-N*count -: N];
            count <= count == 32/N-1 ? 0 : count + 1;
            state <= count == 32/N-1 ? DST_IP : state;
          end
          DST_IP : begin
            axiod <= dst_ip_in[31-N*count -: N];
            count <= count == 32/N-1 ? 0 : count + 1;
            state <= count == 32/N-1 ? NON_IP : state;
            axi_last <= count == 32/N-1 ? 1'b1 : 0;
          end
          NON_IP : begin
            axi_last <= 1'b0;
            axiov <= 1'b0;
            rst_now <= 1'b1;
          end
        endcase
      end else begin
        state <= V_IHL_DSCP_ECN;
        count <= 0;
        axiod <= 0;
        rst_now <= 0;
       // axiov <= 0;
      end
    end
  end

endmodule

`default_nettype wire

`timescale 1ns / 1ps
`default_nettype none

module udp_rx #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [N-1:0] axiid,
  input wire [31:0] src_ip_in,
  input wire [31:0] dst_ip_in,
  input wire [15:0] packet_length_in,
  output logic axiov,
  output logic kill
);

  parameter DST_PORT_COUNT = 16/N;
  parameter LENGTH_COUNT  = 32/N;
  parameter CKSUM_COUNT = 48/N;
  parameter DONE = 64/N;

  logic [15:0] udp_checksum;
  logic [16:0] src_sum, dst_sum, ip_sum, init_data;
  logic init_valid;
  logic [1:0] init_state;
  
  logic [15:0] dst_port, udp_length, cksum;
  logic [$clog2(64/N):0] count;

  logic [15:0] old_cksum_1, old_cksum_2;
  logic [$clog2(16/N)-1:0] cksum_count;
  logic valid_output;

  assign axiov = count >= DONE && udp_length == packet_length_in && (dst_port == 67 || dst_port == 68 || dst_port == 554 || dst_port == 42069); //RTSP

  //assign kill = axiiv ? 0 : ~(old_cksum_2 == 0 || cksum == 0);

  always_ff @(posedge clk) begin
    if (rst) begin
      old_cksum_1 <= 0;
      old_cksum_2 <= 0;
      cksum_count <= 0;
      kill <= 0;
      valid_output <= 0;
    end else begin
      if (axiov) begin
        valid_output <= 1;
      end else begin
        if (axiiv) begin
          valid_output <= 0;
        end
      end
      if (axiiv) begin
        if (cksum_count == 16/N-1) begin
          old_cksum_2 <= old_cksum_1;
          old_cksum_1 <= udp_checksum;
        end
        cksum_count <= cksum_count + 1;
      end else begin
        kill <= valid_output ? ~(old_cksum_2 == 0 || cksum == 0) : 0;
      end
    end
  end

  bland_cksum #(.N(N)) udp_sum(
    .clk(clk),
    .rst(rst),
    .axiiv(axiiv),
    .axiid(axiid),
    .init_valid(init_valid),
    .init_data(init_data[15:0]+init_data[16]),
    .axiov(),
    .axiod(udp_checksum)
  );

  //Minimize combinational chain by adding over a few cycles
  always_ff @(posedge clk) begin
    if (rst) begin
      init_valid <= 0;
      init_data <= 0;
      init_state <= 0;
      src_sum <= 0;
      dst_sum <= 0;
      ip_sum <= 0;
    end else begin
      if (axiiv) begin
        if (init_state == 0) begin
          init_data <= packet_length_in + 16'h11;
          src_sum <= src_ip_in[31:16] + src_ip_in[15:0];
          dst_sum <= dst_ip_in[31:16] + dst_ip_in[15:0];
          init_state <= 2'b01;
        end else if (init_state == 1) begin
          ip_sum <= src_sum[15:0]+src_sum[16]+dst_sum[15:0]+dst_sum[16];
          init_state <= 2'b10;
        end else if (init_state == 2) begin
          init_data <= ip_sum[15:0] + ip_sum[16] + init_data[15:0] + init_data[16];
          init_valid <= 1;
          init_state <= 2'b11;
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      count <= 0;
      cksum <= 0;
      udp_length <= 0;
      dst_port <= 0;
    end else begin
      if (axiiv) begin
        if (count < DST_PORT_COUNT) begin
          count <= count + 1;
        end else if (count < LENGTH_COUNT) begin
          count <= count + 1;
          dst_port[31-N*count -: N] <= axiid;
        end else if (count < CKSUM_COUNT) begin
          count <= count + 1;
          udp_length[47-N*count -: N] <= axiid;
        end else if (count < DONE) begin
          count <= count + 1;
          cksum[63-N*count -: N] <= axiid;
        end
      end else begin
        count <= 0;
      end
    end
  end

endmodule

`default_nettype wire

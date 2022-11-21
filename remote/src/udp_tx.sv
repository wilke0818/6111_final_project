`timescale 1ns / 1ps
`default_nettype none

module udp_tx #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [15:0] src_port_in,
  input wire [15:0] dst_port_in,
  input wire [15:0] data_length_in,
  input wire [15:0] data_checksum_in,
  input wire [31:0] src_ip_in,
  input wire [31:0] dst_ip_in,
  output logic axiov,
  output logic [N-1:0] axiod,
  output logic axi_last
  );

  

  parameter SRC_PORT = 0;
  parameter DST_PORT = 1;
  parameter LENGTH = 2;
  parameter CHECKSUM = 3;
  parameter NON_UDP_SEND = 4;

  
  logic [2:0] state;

  logic [$clog2(16/N)-1:0] count;
  logic [15:0] udp_checksum, udp_length;

  logic [16:0] src_sum, dst_sum, ip_sum, init_data;
  logic init_valid, cksum_valid_in;
  logic [1:0] init_state;

  assign udp_length = data_length_in + 16'd8;
  
  bland_cksum #(.N(N)) udp_cksum (
    .clk(clk),
    .rst(rst),
    .axiiv(axiov),
    .axiid(cksum_valid_in ? axiod : 4'b0),
    .init_valid(init_valid),
    .init_data(init_data[15:0] + init_data[16]),
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
          init_data <= udp_length + 16'h11;
          src_sum <= src_ip_in[31:16] + src_ip_in[15:0];
          dst_sum <= dst_ip_in[31:16] + dst_ip_in[15:0];
          init_state <= 2'b01;
        end else if (init_state == 1) begin
          ip_sum <= src_sum[15:0]+src_sum[16]+dst_sum[15:0]+dst_sum[16];
          init_data <= data_checksum_in + init_data[15:0] + init_data[16];
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
      state <= 0;
      axiov <= 0;
      axiod <= 0;
    end else begin
      if (axiiv) begin
        axiov <= 1'b1;
        case (state)
          SRC_PORT : begin
            cksum_valid_in <= 1'b1;
            axiod <= src_port_in[15-N*count -: N];
            count <= count + 1;
            state <= count == 16/N-1 ? DST_PORT : state;
          end
          DST_PORT : begin
            axiod <= dst_port_in[15-N*count -: N];
            count <= count + 1;
            state <= count == 16/N-1 ? LENGTH : state;
          end
          LENGTH : begin
            axiod <= udp_length[15-N*count -: N];
            count <= count + 1;
            state <= count == 16/N-1 ? CHECKSUM : state;
          end
          CHECKSUM : begin
            axiod <= udp_checksum[15-N*count -: N];
            count <= count + 1;
            state <= count == 16/N-1 ? NON_UDP_SEND : state;
            axi_last <= count == 16/N-1 ? 1'b1 : 0;
            cksum_valid_in <= 0;
          end
          NON_UDP_SEND : begin
            axi_last <= 1'b0;
            axiov <= 1'b0;
          end
        endcase
      end else begin
        state <= SRC_PORT;
        count <= 0;
        axiov <= 0;
      end
    end
  end

endmodule

`default_nettype wire

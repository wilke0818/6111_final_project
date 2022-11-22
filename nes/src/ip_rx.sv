`timescale 1ns / 1ps
`default_nettype none


module internet_protocol_rx #(parameter N=2) (
    input wire clk,
    input wire rst,
    input wire axiiv,
    input wire [N-1:0] axiid,
    output logic axiov,
    output logic [7:0] protocol_out,
    output logic [31:0] src_ip_out,
    output logic [31:0] dst_ip_out,
    output logic [15:0] packet_length_out
  );

  parameter VERSION = 0;
  parameter HEADER = 1;
  parameter DSCP_ECN = 2;
  parameter LENGTH = 3;
  parameter IDENTIFICATION = 4;
  parameter FLAGS = 5;
  parameter TTL = 6;
  parameter PROTOCOL = 7;
  parameter CKSUM = 8;
  parameter SRC = 9;
  parameter DST = 10;
  parameter NOT_IP = 11;
  parameter INVALID_IP = 12;

  //Need to track
  logic [15:0] header_checksum;
  logic [N-1:0] cksum_axiid;
  logic [4:0] count;
  logic [3:0] state;

  //Need to quick check
  logic [3:0] version, header_length;
  logic [3:0] flags;

  assign cksum_axiid = state != NOT_IP && state != INVALID_IP ? axiid : 0;

  bland_cksum #(.N(N)) ip_sum(
    .clk(clk),
    .rst(rst),
    .axiiv(axiiv),
    .axiid(cksum_axiid),
    .axiov(),
    .axiod(header_checksum)
  );

  assign axiov = header_checksum == 0 && state == NOT_IP;

  always_ff @(posedge clk) begin
    if (rst) begin
      count <= 0;
      version <= 0;
      header_length <= 0;
      flags <= 0;
      state <= 0;
    end else begin
      if (axiiv) begin
        if (state == VERSION) begin
          if (count < 4/N - 1) begin
            count <= count + 1;
            version[4-N*count-1 -: N] <= axiid;
          end else begin
            count <= 0;
            state <= HEADER;
            version[4-N*count-1 -: N] <= axiid;
          end
        end else if (state == HEADER) begin
          if (count < 4/N - 1) begin
            count <= count + 1;
            header_length[4-N*count-1 -: N] <= axiid;
          end else begin 
            count <= 0;
            state <= version == 4 ? DSCP_ECN : INVALID_IP;
            header_length[4-N*count-1 -: N] <= axiid;
          end
        end else if (state == DSCP_ECN) begin
          if (count < 8/N - 1) begin
            count <= count + 1;
          end else begin 
            count <= 0;
            state <= header_length == 5 ? LENGTH : INVALID_IP;
          end
        end else if (state == LENGTH) begin
          if (count < 16/N - 1) begin
            count <= count + 1;
            packet_length_out[16-N*count-1 -: N] <= axiid;
          end else begin 
            count <= 0;
            state <= IDENTIFICATION;
            packet_length_out[16-N*count-1 -: N] <= axiid;
          end
        end else if (state == IDENTIFICATION) begin
          if (count < 16/N - 1) begin
            count <= count + 1;
          end else begin 
            count <= 0;
            state <= FLAGS;
          end
        end else if (state == FLAGS) begin
          if (count < 4/N - 1) begin 
            count <= count + 1;
            flags[3-N*count -: N] <= axiid;
          end else if (count < 8/N - 1) begin
            count <= count + 1;
            flags[3-N*count -: N] <= axiid;
          end else if (count < 16/N -1) begin
            count <= count + 1;
          end else begin 
            count <= 0;
            state <= flags[3:1] == 3'b010 ? TTL : INVALID_IP;
          end
        end else if (state == TTL) begin
          if (count < 8/N - 1) begin
            count <= count + 1;
          end else begin
            count <= 0;
            state <= PROTOCOL;
          end
        end else if (state == PROTOCOL) begin
          if (count < 8/N - 1) begin
            count <= count + 1;
            protocol_out[7-N*count -: N] <= axiid;
          end else begin
            count <= 0;
            state <= CKSUM;
            protocol_out[7-N*count -: N] <= axiid;
          end
        end else if (state == CKSUM) begin
          if (count < 16/N - 1) begin
            count <= count + 1;
          end else begin
            count <= 0;
            state <= SRC;
          end
        end else if (state == SRC) begin
          if (count < 32/N - 1) begin
            count <= count + 1;
            src_ip_out[31-(count*N) -: N] <= axiid;
          end else begin
            count <= 0;
            state <= DST;
            src_ip_out[31-(count*N) -: N] <= axiid;
          end
        end else if (state == DST) begin
          if (count < 32/N - 1) begin
            count <= count + 1;
            dst_ip_out[31-(count*N) -: N] <= axiid;
          end else begin
            count <= 0;
            state <= NOT_IP;
            dst_ip_out[31-(count*N) -: N] <= axiid;
          end
        end
      end else begin
        count <= 0;
        version <= 0;
        header_length <= 0;
        flags <= 0;
        state <= VERSION;
      end
    end

  end

endmodule

`default_nettype wire

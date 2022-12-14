`timescale 1ns / 1ps
`default_nettype none


module ether_tx #(parameter N=2) (
  input wire clk,             // clock @ 25 or 50 mhz
  input wire rst,             // btnc (used for reset)
  input wire axiiv,           // AXI Input Valid
  input wire [47:0] my_mac,   // MAC address of this FPGA
  input wire [47:0] dest_mac, // MAC address of destination device
  input wire [15:0] etype,    // Ethernet type
  output logic axiov,         // Transmitting valid data
  output logic [N-1:0] axiod, // Data being transmitted
  output logic axio_cksum,    // Valid when checksum should be calculated
  output logic axi_last
  );

  // NOTE: Transmits in MSB/MSB order, so must route through bitorder before sending

  parameter PRE_COUNT = (56/N)-1;

  enum {IDLE, SEND_PREAMBLE, SEND_SFD, SEND_DEST_MAC, SEND_SRC_MAC, SEND_TYPE, SEND_DATA, SEND_CRC} state;


  //local variables
  logic [15:0] ethertype;
  logic [15:0] length;
  logic [15:0] crc;

  logic [7:0] preamble_count;
  logic [1:0] sfd_count;
  logic [15:0] mac_count = 47;
  logic [15:0] type_count = 15;
  
  // FIXME: Currently beings transmission as soon as axiiv is asserted
  //        May need to change to something like axi_last in the future

  always_ff @(posedge clk ) begin
    if (rst)begin
      axio_cksum <= 0;
      mac_count <= 47;
      type_count <= 15;
      state <= IDLE;
      axiov <= 0;
      preamble_count <= 0;
      sfd_count <= 0;
    end else begin
      case (state)
        IDLE: begin
          axio_cksum <= 0;
          mac_count <= 47;
          type_count <= 15;
          state <= IDLE;
          axiov <= 0;
          preamble_count <= 0;
          sfd_count <= 0;
          axi_last <= 1'b0;
          if (axiiv) begin
            state <= SEND_PREAMBLE;
            axiov <= 1'b1;
            if (N==2)begin
              axiod <= 2'b01;
            end else begin
              axiod <= 4'b0101;
            end
          end
        end

        SEND_PREAMBLE: begin
          axiov <= 1;
          if (N==2)begin
            axiod <= 2'b01;
          end else begin
            axiod <= 4'b0101;
          end
          if (preamble_count == PRE_COUNT-1) begin
            state <= SEND_SFD;
            preamble_count <= 0;
          end
          preamble_count <= preamble_count + 1;
        end

        SEND_SFD: begin
          if (N==2)begin
            if (sfd_count == 0) begin
              axiod <= 2'b11;
            end else begin
              axiod <= 2'b01;
            end
            sfd_count <= sfd_count + 1;
          end else begin
            if (sfd_count == 0) begin
              axiod <= 4'b1101;
            end else begin
              axiod <= 4'b0101;
            end
            sfd_count <= sfd_count + 1;
          end

          if ((N==2) && sfd_count == 2'b11) begin
            state <= SEND_DEST_MAC;
            sfd_count <= 0;
  //          axio_cksum <= 1'b1;
          end else if ((N==4) && sfd_count == 2'b01) begin
            state <= SEND_DEST_MAC;
            sfd_count <= 0;
//            axio_cksum <= 1'b1;
          end
        end

        SEND_DEST_MAC: begin
          axio_cksum <= 1'b1;
          if (N==2)begin
            axiod <= dest_mac[mac_count -: 2];
            mac_count <= mac_count - 2;
          end else begin
            axiod <= dest_mac[mac_count -: 4];
            mac_count <= mac_count - 4;
          end
          if (N==2 && mac_count == 1) begin
            mac_count <= 47;
            state <= SEND_SRC_MAC;
          end else if (N==4 && mac_count == 3) begin
            mac_count <= 47;
            state <= SEND_SRC_MAC;
          end
        end

        SEND_SRC_MAC: begin
          if (N==2)begin
            axiod <= my_mac[mac_count -: 2];
            mac_count <= mac_count - 2;
          end else begin
            axiod <= my_mac[mac_count -: 4];
            mac_count <= mac_count - 4;
          end
          if (N==2 && mac_count == 1) begin
            state <= SEND_TYPE;
          end else if (N==4 && mac_count == 3) begin
            state <= SEND_TYPE;
          end
        end

        SEND_TYPE: begin
          if (N==2)begin
            axiod <= etype[type_count -: 2];
            type_count <= type_count - 2;
          end else begin
            axiod <= etype[type_count -: 4];
            type_count <= type_count - 4;
          end
          if (N==2 && type_count == 1) begin
            axiov <= 0;
            axi_last <= 1'b1;
            // axio_cksum <= 0;
            state <= IDLE;
          end else if (N==4 && type_count == 3) begin
            axiov <= 0;
            // axio_cksum <= 0;
            state <= IDLE;
            axi_last <= 1'b1;
          end
        end
      endcase
    end
  end


endmodule
`default_nettype wire

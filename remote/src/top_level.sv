`timescale 1ns / 1ps
`default_nettype none

module top_level(
  input wire clk, //clock @ 100 mhz
  input wire btnc, //btnc (used for reset)
  input wire btnl,
 // input wire btnr,
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
  
//  logic [1599:0] display_out;
//  logic [20:0] display_count;

 // logic old_right, new_right;

  divider ether_clk( 
    .clk(clk),
    .ethclk(eth_refclk)
  );

  debouncer btnc_db(.clk_in(eth_refclk),
                  .rst_in(sys_rst),
                  .dirty_in(btnl),
                  .clean_out(send_button));

//  debouncer btnr_db(.clk_in(eth_refclk),
  //                .rst_in(sys_rst),
    //              .dirty_in(btnr),
      //            .clean_out(new_right));

  network_stack_tx #(.N(N), .DATA_SIZE(DATA_SIZE)) da_net_tx(
    .clk(eth_refclk),
    .rst(sys_rst),
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

  network_stack_rx #(.N(N), .DATA_SIZE(DATA_SIZE)) da_net_rx(
    .clk(eth_refclk),
    .rst(sys_rst),
    .eth_rxd(eth_rxd),
    .eth_crsdv(eth_crsdv),
    .mac(MY_MAC),
    .dst_mac(48'hFF_FF_FF_FF_FF_FF),
    .dst_ip_in(32'hFF_FF_FF_FF),
    .transport_protocol_in(8'h11),
    .ethertype_in(16'h0800),
    .udp_src_port_in(16'd42069),
    .udp_dst_port_in(16'd42069),
    .axiov(),
    .axiod()
  );



  // seven_segment_controller mssc(.clk_in(eth_refclk),
        //                         .rst_in(sys_rst),
        //                          .val_in(display_out[1599-display_count*4 -: 32]),
        //                          .cat_out({cg, cf, ce, cd, cc, cb, ca}),
        //                          .an_out(an));


  // Frame buffer stuff
  // 12x(240x256) BRAM
  // Pixel decoder
  // Frame buffer
  // VGA module
  /*

  logic [15:0] bram_addr_frameb;
  logic axiov_frameb;
  logic [11:0] bram_datain_frameb;
  logic [15:0] pixel_addr_out;
  logic [11:0] frame_buff;

  logic axiov_pixeldec;
  logic [11:0] axiod_pixeldec;
  logic [7:0] line_y_pixeldec;
  logic axiov_frameb;



  //Two Clock Frame Buffer:
  //Data written on 16.67 MHz (From camera)
  //Data read on 65 MHz (start of video pipeline information)
  //Latency is 2 cycles.
  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(12),
    .RAM_DEPTH(256*240))
    frame_buffer (
    //Write Side (100 MHz)
    .addra(bram_addr_frameb),
    .clka(clk_100mhz),
    .wea(axiov_frameb),
    .dina(bram_datain_frameb),
    .ena(1'b1),
    .regcea(1'b1),
    .rsta(sys_rst),
    .douta(),
    //Read Side (65 MHz)
    .addrb(pixel_addr_out),
    .dinb(16'b0),
    .clkb(clk_65mhz),
    .web(1'b0),
    .enb(1'b1),
    .rstb(sys_rst),
    .regceb(1'b1),
    .doutb(frame_buff)
  );
  assign pixel_addr_out = (vcount * 256 + hcount);
  assign color = frame_buff;

  logic [10:0] hcount;    // pixel on current line
  logic [9:0] vcount;     // line number
  logic hsync, vsync, blank; //control signals for vga

  vga vga_gen(
    .pixel_clk_in(clk_65mhz),
    .hcount_out(hcount),
    .vcount_out(vcount),
    .hsync_out(hsync),
    .vsync_out(vsync),
    .blank_out(blank));

    // DON'T FORGET TO ADD vga_{rgb} AND vga_hs/vs TO OUTPUTS
    
  pixel_decoder pixel_m
    ( .clk(clk_100mhz)
    , .rst(sys_rst)
    , .axiiv(axiov_nstack)
    , .axiid(axiod_nstack)
    , .axiov(axiov_pixeldec)
    , .axiod(axiod_pixeldec)
    , .line_y(line_y_pixeldec)
    );

  framebuffer frame_m
    #( .FRAME_WIDTH(256) )
    ( .clk(clk_100mhz)
    , .rst(sys_rst)
    , .axiiv(axiov_pixeldec)
    , .axiid(axiod_pixeldec)
    , .line_y(line_y_pixeldec)
    , .axiov(axiov_frameb)
    , .bram_addr(bram_addr_frameb)
    , .bram_data_in(bram_datain_frameb)
    );
    
    // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~blank ? color[11:8]: 0;
    assign vga_g = ~blank ? color[7:4] : 0;
    assign vga_b = ~blank ? color[3:0] : 0;

    assign vga_hs = ~hsync;
    assign vga_vs = ~vsync;
    */

  always_ff @(posedge eth_refclk) begin
    if (sys_rst) begin
      old_send_button <= 0;
      test_data_valid_in <= 0;
      test_data_in <= 0;
      test_count <= 0;
    //  display_out <= 0;
    //  display_count <= 0;
    end else begin
      old_send_button <= send_button;
    //  old_right <= new_right;
    //  if (eth_txen) begin
    //    display_out <= {display_out[1597:0], eth_txd[0], eth_txd[1]};
    //  end

    //  if (~old_right && new_right) begin
    //    display_count <= display_count + 1;
    //  end

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

`define CP	40
`define HCP	(`CP / 2)

/* checking helper for testing tasks */
`define CHECK(COND, TESTOK, MSG) do begin	\
	if (!(COND) && TESTOK) begin		\
		$display("FAIL: %s", MSG);	\
		TESTOK = 0;			\
	end					\
end while (0)

`default_nettype none
`timescale 1ns / 1ps

`define MSG	64'h67_69_60_d1_9d_78_5a_5b
`define CRC	32'h96_cb_5e_37

/* the result of the crc32-bzip2 is
 * post-complemented during transmission.
 * as a result, we'll no longer end up with
 * a zero result when we shift the crc32 into
 * our LFSR. instead, we get this non-zero
 * magic value which should be consistent
 * across sends
 */
`define MAGIC_CHECK 32'h38_fb_22_84

module crc32sim;

	logic clk;
	logic rst;
	logic axiiv;
	logic [3:0] axiid;
	logic axiov;
	logic [31:0] axiod;

	logic [0:63] msg;
	logic [0:31] rcrc;
	logic testok;

	integer i;

	crc32_4bit uut(.clk(clk), .rst(rst), .crc_en(axiiv), .data_in(axiid),
		  .crc_out_en(axiov), .crc_out(axiod));

	initial begin: CLK
		clk = 1;
		forever #`HCP clk = ~clk;
	end

	initial begin: MAIN
`ifdef MKWAVEFORM
		$dumpfile("obj/crc32-bzip2-dp.vcd");
		$dumpvars(0, crcsim);
`endif /* MKWAVEFORM */

		/* spin up the lfsr */
		testok = 1;
		msg = `MSG;

		rst = 1;
		axiiv = 0;
		axiid = 0;
		#`CP;

		rst = 0;
		#`CP;

		$display("== test one: correct CRC generation ==");

		for (i = 0; i < 64; i = i + 4) begin
			axiiv = 1;
			axiid = {msg[i], msg[i+1], msg[i+2], msg[i+3]};

			if (!axiov) testok = 0;
			#`CP;
		end

		axiid = 0;
		axiiv = 0;

		for (i = 0; i < 2; i = i + 1) begin
			if (!axiov) testok = 0;
			else if (axiod != `CRC) testok = 0;
			#`CP;
		end

		if (^axiod === 1'bX) testok = 0;
		else if (^axiov === 1'bX) testok = 0;

		$display("== test one result: %s", (testok) ? "OK" : "FAIL");
		if (!testok) $finish;

		rst = 1;
		axiiv = 0;
		axiid = 0;
		#`CP;

		rst = 0;
		#`CP;

		$display("== test two: correct residue generation ==");

		for (i = 0; i < 64; i = i + 4) begin
			axiiv = 1;
			axiid = {msg[i], msg[i+1], msg[i+2], msg[i+3]};

			if (!axiov) testok = 0;
			#`CP;
		end
		
		rcrc = axiod;

		for (i = 0; i < 32; i = i + 4) begin
			axiiv = 1;
			axiid = {rcrc[i], rcrc[i+1], rcrc[i+2], rcrc[i+3]};

			if (!axiov) testok = 0;
			#`CP;
		end

		axiid = 0;
		axiiv = 0;

		for (i = 0; i < 2; i = i + 1) begin
			if (!axiov) testok = 0;
			else if (axiod != `MAGIC_CHECK) testok = 0;
			#`CP;
		end

		if (^axiod === 1'bX) testok = 0;
		else if (^axiov === 1'bX) testok = 0;

		$display("== test two result: %s", (testok) ? "OK" : "FAIL");
		$finish;
	end
endmodule

`default_nettype wire

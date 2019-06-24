module top (
	input  clk,
	output LED1,
	output LED2,
	output LED3,
	output LED4,
	output LED5,
	input arduino6,
	input arduino7,
	input arduino8,
	input arduino9,
	output arduino10,
	output arduino11
);
	
	wire out0, out1;
	nand_null nand_test(arduino6, arduino7, arduino8, arduino9, out0, out1);

	assign arduino10 = out0;
	assign arduino11 = out1;

	assign LED2 = out0;
	assign LED3 = out1;

endmodule

module nand_null(input x0, input x1,
				 input y0, input y1,
				 output o0, output o1);

	SB_LUT4 #(
		.LUT_INIT(16'b1001000000101000)
	) out0 (
		.O(o0),
		.I0(y1),
		.I1(y0),
		.I2(x1),
		.I3(x0)
	);

	SB_LUT4 #(
		.LUT_INIT(16'b1001011001001000)
	) out1 (
		.O(o1),
		.I0(y1),
		.I1(y0),
		.I2(x1),
		.I3(x0)
	);

endmodule


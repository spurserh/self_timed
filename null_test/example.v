
localparam IN_BITS = 6;
localparam OUT_BITS = 4;
localparam IN_ADDR_BITS = 4;
localparam OUT_ADDR_BITS = 4;

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
	input arduino11
);
	wire [(IN_BITS-1):0] inputs;
	wire [(OUT_BITS-1):0] outputs;

	serial_tester tester(
		.in_clk(arduino6),
		.in_data(arduino7),
		.in_rst(arduino8),
		.out_clk(arduino9),
		.out_data(arduino10),
		.out_rst(arduino11),
		.inputs(inputs),
		.output_vals(outputs)
	);

	assign {LED1, LED2, LED3, LED4, LED5} = inputs[4:0];

	full_add_null full_add0_0(
		.a(inputs[1:0]),
		.b(inputs[3:2]),
		.c_in(inputs[5:4]),
		.s(outputs[1:0]),
		.c_out(outputs[3:2])
	);

endmodule

module full_add_null(input [1:0] a,
					 input [1:0] b,
					 input [1:0] c_in,
					 output [1:0] s,
					 output [1:0] c_out);
	// First layer
	wire [1:0] xor0_out;
	wire [1:0] and0_out;
	xor_null xor0(a, b, xor0_out);
	and_null and0(a, b, and0_out);

	// Second layer
	wire [1:0] and1_out;
	and_null and1(xor0_out, c_in, and1_out);
	xor_null xor1(xor0_out, c_in, s);

	// Third layer
	wire [1:0] or2_out;
	or_null or2(and0_out, and1_out, c_out);
endmodule

module nand_null(input [1:0] x,
				 input [1:0] y,
				 output [1:0] o);

	SB_LUT4 #(
		.LUT_INIT(16'b1001000000101000)
	) out0 (
		.O(o[0]),
		.I0(y[1]),
		.I1(y[0]),
		.I2(x[1]),
		.I3(x[0])
	);

	SB_LUT4 #(
		.LUT_INIT(16'b1001011001001000)
	) out1 (
		.O(o[1]),
		.I0(y[1]),
		.I1(y[0]),
		.I2(x[1]),
		.I3(x[0])
	);

endmodule

module and_null(input [1:0] x,
				 input [1:0] y,
				 output [1:0] o);

	SB_LUT4 #(
		.LUT_INIT(16'b1001011001001000)
	) out0 (
		.O(o[0]),
		.I0(y[1]),
		.I1(y[0]),
		.I2(x[1]),
		.I3(x[0])
	);

	SB_LUT4 #(
		.LUT_INIT(16'b1001000000101000)
	) out1 (
		.O(o[1]),
		.I0(y[1]),
		.I1(y[0]),
		.I2(x[1]),
		.I3(x[0])
	);

endmodule

module or_null(input [1:0] x,
				 input [1:0] y,
				 output [1:0] o);

	SB_LUT4 #(
		.LUT_INIT(16'b1001010000001000)
	) out0 (
		.O(o[0]),
		.I0(y[1]),
		.I1(y[0]),
		.I2(x[1]),
		.I3(x[0])
	);

	SB_LUT4 #(
		.LUT_INIT(16'b1001001001101000)
	) out1 (
		.O(o[1]),
		.I0(y[1]),
		.I1(y[0]),
		.I2(x[1]),
		.I3(x[0])
	);

endmodule

module xor_null(input [1:0] x,
				 input [1:0] y,
				 output [1:0] o);

	SB_LUT4 #(
		.LUT_INIT(16'b1001010000101000)
	) out0 (
		.O(o[0]),
		.I0(y[1]),
		.I1(y[0]),
		.I2(x[1]),
		.I3(x[0])
	);

	SB_LUT4 #(
		.LUT_INIT(16'b1001001001001000)
	) out1 (
		.O(o[1]),
		.I0(y[1]),
		.I1(y[0]),
		.I2(x[1]),
		.I3(x[0])
	);

endmodule

module serial_tester(input in_clk,
					 input in_data,
					 input in_rst,
					 input out_clk,
					 output out_data,
					 input out_rst,
					 output reg [(IN_BITS-1):0] inputs,
					 input [(OUT_BITS-1):0] output_vals
					 );
	reg [(IN_ADDR_BITS-1):0] input_idx = 0;

	always @(posedge in_clk)
	begin
		if(in_rst) begin
			input_idx <= 0;
			inputs <= 0;
		end else begin
			inputs[input_idx] <= in_data;
			input_idx <= input_idx + 1;
		end
	end

	reg [(OUT_ADDR_BITS-1):0] output_idx = 0;
	reg [(IN_BITS-1):0] outputs = 0;

	assign out_data = outputs[output_idx];

	always @(posedge out_clk)
	begin
		if(out_rst) begin
			output_idx <= 0;
			outputs <= output_vals;
		end else begin
			output_idx <= output_idx + 1;
		end
	end
endmodule

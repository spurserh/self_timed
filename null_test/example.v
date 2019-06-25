
localparam IN_BITS = 48;
localparam OUT_BITS = 53;
localparam IN_ADDR_BITS = 6;
localparam OUT_ADDR_BITS = 6;

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
	input arduino11,
	output arduino12
);
	wire [(IN_BITS-1):0] serial_inputs;
	reg [(IN_BITS-1):0] last_vals = 48'b010101010101010101010101010101010101010101010110;
	wire [(IN_BITS-1):0] outputs;

	reg work_phase = 0;
	reg high_null_phase = 1;

	wire data_is_ready;
	wire high_null_ready;
	wire low_null_ready;

	wire [(OUT_BITS-1):0] serial_outputs = {high_null_ready, low_null_ready, data_is_ready, work_phase, high_null_phase,  /* outputs */  /*combo_inputs*/ last_vals};

	serial_tester tester(
		.in_clk(arduino6),
		.in_data(arduino7),
		.in_rst(arduino8),
		.out_clk(arduino9),
		.out_data(arduino10),
		.out_rst(arduino11),
		.inputs(serial_inputs),
		.output_vals(serial_outputs)
	);

//	assign {LED1, LED2, LED3, LED4, LED5} = inputs[4:0];
//	assign LED1 = high_null_phase;
//	assign LED2 = work_phase;
	assign arduino12 = 0;

	data_ready dr(outputs, data_is_ready);
	high_null_ready hnr(outputs, high_null_ready);
	low_null_ready lnr(outputs, low_null_ready);
	wire phase_finished = low_null_ready | high_null_ready | data_is_ready;

	// HACK: Stop the optimizer from messing with these..
	assign LED1 = combo_inputs[0];
	assign LED2 = last_vals[0];

	assign LED3 = high_null_ready;
	assign LED4 = low_null_ready;
	assign LED5 = data_is_ready;

	wire [(IN_BITS-1):0] combo_inputs;

	always @(*)
	begin
		if(work_phase) begin
			combo_inputs = last_vals;
		end else if(high_null_phase) begin
			combo_inputs = 48'b111111111111111111111111111111111111111111111111;
		end else begin
			combo_inputs = 48'b000000000000000000000000000000000000000000000000;
		end
	end

	always @(posedge data_is_ready)
	begin
		last_vals <= outputs;
	end


//  always @(posedge phase_finished)
	always @(*)
	begin
		if(data_is_ready) begin
			high_null_phase <= 1;
			work_phase <= 0;
		end else if(high_null_ready) begin
			high_null_phase <= 0;
			work_phase <= 0;
		end else if(low_null_ready) begin
			high_null_phase <= 0;
			work_phase <= 1;
		end
	end

	inc_test test(combo_inputs, outputs);

endmodule

module data_ready(input [(IN_BITS-1):0] outputs,
					  output ready);
    assign ready = (outputs[0 ] ^ outputs[1]) &
                   (outputs[2 ] ^ outputs[3]) &
                   (outputs[4 ] ^ outputs[5]) &
                   (outputs[6 ] ^ outputs[7]) &
                   (outputs[8 ] ^ outputs[9]) &
                   (outputs[10] ^ outputs[11]) &
                   (outputs[12] ^ outputs[13]) &
                   (outputs[14] ^ outputs[15]) &
                   (outputs[16] ^ outputs[17]) &
                   (outputs[18] ^ outputs[19]) &
                   (outputs[20] ^ outputs[21]) &
                   (outputs[22] ^ outputs[23]) &
                   (outputs[24] ^ outputs[25]) &
                   (outputs[26] ^ outputs[27]) &
                   (outputs[28] ^ outputs[29]) &
                   (outputs[30] ^ outputs[31]) &
                   (outputs[32] ^ outputs[33]) &
                   (outputs[34] ^ outputs[35]) &
                   (outputs[36] ^ outputs[37]) &
                   (outputs[38] ^ outputs[39]) &
                   (outputs[40] ^ outputs[41]) &
                   (outputs[42] ^ outputs[43]) &
                   (outputs[44] ^ outputs[45]) &
                   (outputs[46] ^ outputs[47]);
endmodule

module high_null_ready(input [(IN_BITS-1):0] outputs,
					  output ready);
    assign ready = (outputs[0 ] & outputs[1]) &
                   (outputs[2 ] & outputs[3]) &
                   (outputs[4 ] & outputs[5]) &
                   (outputs[6 ] & outputs[7]) &
                   (outputs[8 ] & outputs[9]) &
                   (outputs[10] & outputs[11]) &
                   (outputs[12] & outputs[13]) &
                   (outputs[14] & outputs[15]) &
                   (outputs[16] & outputs[17]) &
                   (outputs[18] & outputs[19]) &
                   (outputs[20] & outputs[21]) &
                   (outputs[22] & outputs[23]) &
                   (outputs[24] & outputs[25]) &
                   (outputs[26] & outputs[27]) &
                   (outputs[28] & outputs[29]) &
                   (outputs[30] & outputs[31]) &
                   (outputs[32] & outputs[33]) &
                   (outputs[34] & outputs[35]) &
                   (outputs[36] & outputs[37]) &
                   (outputs[38] & outputs[39]) &
                   (outputs[40] & outputs[41]) &
                   (outputs[42] & outputs[43]) &
                   (outputs[44] & outputs[45]) &
                   (outputs[46] & outputs[47]);
endmodule

module low_null_ready(input [(IN_BITS-1):0] outputs,
					  output ready);
    assign ready = ((!outputs[0 ]) & (!outputs[1])) &
                   ((!outputs[2 ]) & (!outputs[3])) &
                   ((!outputs[4 ]) & (!outputs[5])) &
                   ((!outputs[6 ]) & (!outputs[7])) &
                   ((!outputs[8 ]) & (!outputs[9])) &
                   ((!outputs[10]) & (!outputs[11])) &
                   ((!outputs[12]) & (!outputs[13])) &
                   ((!outputs[14]) & (!outputs[15])) &
                   ((!outputs[16]) & (!outputs[17])) &
                   ((!outputs[18]) & (!outputs[19])) &
                   ((!outputs[20]) & (!outputs[21])) &
                   ((!outputs[22]) & (!outputs[23])) &
                   ((!outputs[24]) & (!outputs[25])) &
                   ((!outputs[26]) & (!outputs[27])) &
                   ((!outputs[28]) & (!outputs[29])) &
                   ((!outputs[30]) & (!outputs[31])) &
                   ((!outputs[32]) & (!outputs[33])) &
                   ((!outputs[34]) & (!outputs[35])) &
                   ((!outputs[36]) & (!outputs[37])) &
                   ((!outputs[38]) & (!outputs[39])) &
                   ((!outputs[40]) & (!outputs[41])) &
                   ((!outputs[42]) & (!outputs[43])) &
                   ((!outputs[44]) & (!outputs[45])) &
                   ((!outputs[46]) & (!outputs[47]));
endmodule

module inc_test(input [(IN_BITS-1):0] inputs,
			    output [(IN_BITS-1):0] outputs);
	wire [1:0] c0;
	inc_null inc0(
		.a(inputs[1:0]),
		.s(outputs[1:0]),
		.c_out(c0)
	);

	wire [1:0] c1;
	carry_null inc1(
		.a(inputs[3:2]),
		.c_in(c0),
		.s(outputs[3:2]),
		.c_out(c1)
	);

	wire [1:0] c2;
	carry_null inc2(
		.a(inputs[5:4]),
		.c_in(c1),
		.s(outputs[5:4]),
		.c_out(c2)
	);

	wire [1:0] c3;
	carry_null inc3(
		.a(inputs[7:6]),
		.c_in(c2),
		.s(outputs[7:6]),
		.c_out(c3)
	);

	wire [1:0] c4;
	carry_null inc4(
		.a(inputs[9:8]),
		.c_in(c3),
		.s(outputs[9:8]),
		.c_out(c4)
	);

	wire [1:0] c5;
	carry_null inc5(
		.a(inputs[11:10]),
		.c_in(c4),
		.s(outputs[11:10]),
		.c_out(c5)
	);

	wire [1:0] c6;
	carry_null inc6(
		.a(inputs[13:12]),
		.c_in(c5),
		.s(outputs[13:12]),
		.c_out(c6)
	);

	wire [1:0] c7;
	carry_null inc7(
		.a(inputs[15:14]),
		.c_in(c6),
		.s(outputs[15:14]),
		.c_out(c7)
	);

	wire [1:0] c8;
	carry_null inc8(
		.a(inputs[17:16]),
		.c_in(c7),
		.s(outputs[17:16]),
		.c_out(c8)
	);

	wire [1:0] c9;
	carry_null inc9(
		.a(inputs[19:18]),
		.c_in(c8),
		.s(outputs[19:18]),
		.c_out(c9)
	);

	wire [1:0] c10;
	carry_null inc10(
		.a(inputs[21:20]),
		.c_in(c9),
		.s(outputs[21:20]),
		.c_out(c10)
	);

	wire [1:0] c11;
	carry_null inc11(
		.a(inputs[23:22]),
		.c_in(c10),
		.s(outputs[23:22]),
		.c_out(c11)
	);

	wire [1:0] c12;
	carry_null inc12(
		.a(inputs[25:24]),
		.c_in(c11),
		.s(outputs[25:24]),
		.c_out(c12)
	);

	wire [1:0] c13;
	carry_null inc13(
		.a(inputs[27:26]),
		.c_in(c12),
		.s(outputs[27:26]),
		.c_out(c13)
	);

	wire [1:0] c14;
	carry_null inc14(
		.a(inputs[29:28]),
		.c_in(c13),
		.s(outputs[29:28]),
		.c_out(c14)
	);

	wire [1:0] c15;
	carry_null inc15(
		.a(inputs[31:30]),
		.c_in(c14),
		.s(outputs[31:30]),
		.c_out(c15)
	);

	wire [1:0] c16;
	carry_null inc16(
		.a(inputs[33:32]),
		.c_in(c15),
		.s(outputs[33:32]),
		.c_out(c16)
	);

	wire [1:0] c17;
	carry_null inc17(
		.a(inputs[35:34]),
		.c_in(c16),
		.s(outputs[35:34]),
		.c_out(c17)
	);

	wire [1:0] c18;
	carry_null inc18(
		.a(inputs[37:36]),
		.c_in(c17),
		.s(outputs[37:36]),
		.c_out(c18)
	);

	wire [1:0] c19;
	carry_null inc19(
		.a(inputs[39:38]),
		.c_in(c18),
		.s(outputs[39:38]),
		.c_out(c19)
	);

	wire [1:0] c20;
	carry_null inc20(
		.a(inputs[41:40]),
		.c_in(c19),
		.s(outputs[41:40]),
		.c_out(c20)
	);

	wire [1:0] c21;
	carry_null inc21(
		.a(inputs[43:42]),
		.c_in(c20),
		.s(outputs[43:42]),
		.c_out(c21)
	);

	wire [1:0] c22;
	carry_null inc22(
		.a(inputs[45:44]),
		.c_in(c21),
		.s(outputs[45:44]),
		.c_out(c22)
	);

	wire [1:0] c23;
	carry_null inc23(
		.a(inputs[47:46]),
		.c_in(c22),
		.s(outputs[47:46]),
		.c_out(c23)
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

module inc_null(input [1:0] a,
				 output [1:0] s,
				 output [1:0] c_out);
	inv_null inv(a, s);
	assign c_out = a;
endmodule

module carry_null(input [1:0] a,
					 input [1:0] c_in,
					 output [1:0] s,
					 output [1:0] c_out);

	wire [1:0] and1_out;
	and_null and1(a, c_in, c_out);
	xor_null xor1(a, c_in, s);

endmodule

module inv_null(input [1:0] x,
				 output [1:0] o);
	assign o[1] = x[0];
	assign o[0] = x[1];
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
	reg [(OUT_BITS-1):0] outputs = 0;

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

module top (
	input  clk,
	output LED1,
	output LED2,
	output LED3,
	output LED4,
	output LED5,
	input arduino7
);

wire enable = 1; // arduino7

// ring oscillator
wire chain_in, chain_out;

wire [99:0] buffers_in, buffers_out;
assign buffers_in = {buffers_out[98:0], chain_in};
assign chain_out = buffers_out[99];
assign chain_in = enable ? !chain_out : 0;

SB_LUT4 #(
	.LUT_INIT(16'd2)
) buffers [99:0] (
	.O(buffers_out),
	.I0(buffers_in),
	.I1(1'b0),
	.I2(1'b0),
	.I3(1'b0)
);

reg [20:0] counter = 0;
always @(posedge chain_out) begin
	counter <= counter + 1;
end

assign LED1 = counter[20];

endmodule


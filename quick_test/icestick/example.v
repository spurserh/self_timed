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
	input arduino10,
	input arduino11,
	output arduino12,
	input arduino13  // UNO LED!
);

	assign LED1 = arduino6;
	assign LED2 = arduino7;
	assign LED3 = arduino8;

	reg myreg = 0;

	always @(*) begin
		if(arduino6) begin
			myreg = arduino7 & arduino8;
		end
	end

	assign arduino12 = myreg;
	assign LED5 = myreg;

endmodule

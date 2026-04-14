// 11-bit register to hold a single DMX slot with the start bit and 2 stop
// bits

module slot_register(
	input		clk,
	input		dmx,
	output [10:0]	slot
	);
	reg in_bit;
	// Extra bit for beginning of shift register
	reg [11:0] shift_reg;
	/*
	initial begin
		shift_reg <= 12'd0;
	end
	*/
	always @(dmx) begin
		in_bit = dmx;
	end
	always @(posedge clk) begin
		shift_reg[11] = in_bit;
		shift_reg = shift_reg >> 1;
	end
	assign slot = shift_reg[10:0];

endmodule


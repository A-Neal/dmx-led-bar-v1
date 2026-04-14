// A register to store the first byte in the DMX frame, and output a signal if
// it is non-zero

module byte_zero_reg(
	input		clk,
	input		shift_in,
	input [7:0]	data_in,
	output		non_zero
	);
	reg [7:0] data;
	reg trig;
	always @(posedge clk) begin
		trig <= shift_in;
	end
	reg trig_dly;
	always @(posedge clk) begin
		trig_dly <= trig;
		if(trig && !trig_dly) begin
			data <= data_in;
		end
	end
	assign non_zero = (data != 8'd0);
endmodule


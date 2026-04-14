// module to trigger the PWM pre-registers in sequence when the set DMX address
// is detected

module address_trigger(
	input		clk,
	input		reset,
	input		prime,
	input 		inc,
	input		slot_end,
	output [5:0]	trig_out
	);
	localparam IDLE		= 1'b0;
	localparam DETECTED	= 1'b1;
	reg state;
	reg [6:0] shift_reg;
	/*
	initial begin
		state <= IDLE;
		shift_reg <= 7'b0000001;
	end
	*/
	wire trig;
	assign trig = ( reset | prime | inc );
	reg trig_dly;
	always @(trig) begin
		trig_dly <= trig;
		if(trig && !trig_dly) begin
			if(reset) begin
				state <= IDLE;
				shift_reg = 7'b0000001;
			end else if(prime) begin
				state <= DETECTED;
			end else if(inc) begin
				if(state == DETECTED) begin
					shift_reg <= shift_reg << 1;
				end
			end
		end
	end
	assign trig_out = shift_reg[6:1];// & slot_end;
endmodule


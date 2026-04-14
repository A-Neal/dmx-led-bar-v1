// PWM Controller for the DMX Decoder

module pwm_controller(
	input		enable,
	input		clk,
	input		shift_in,
	input [7:0]	byte_in,
	output		pwm
	);
	reg [7:0] value;
	reg [7:0] counter;
	reg en_reg;
	reg clk_div;
	/*
	initial begin
		value <= 8'd0;
		counter <= 8'd0;
	end
	*/
	reg shift_in_dly;
	always @(posedge clk) begin
		shift_in_dly <= shift_in;
		if(shift_in && !shift_in_dly) begin
			value <= byte_in;
		end
	end
	always @(posedge clk) begin
		en_reg <= enable;
		clk_div <= ~clk_div;
	end
	reg clk_div_dly;
	always @(posedge clk) begin
		clk_div_dly <= clk_div;
		if(clk_div && !clk_div_dly) begin
			counter <= counter + 1;
		end
	end

	// Output is ON when LOW
	assign pwm = (~en_reg | (counter >= value));

endmodule


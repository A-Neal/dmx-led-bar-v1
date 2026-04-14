// This module counts errors that occur in a DMX frame, and outputs a signal
// if an error has occured to prevent data from a malformed or mal-received
// DMX data frame from being shifted into the output PWM registers.

module slot_error_detector(
	input		clk,
	input		check,
	input [10:0]	slot,
	input		reset,
	output		error
	);
	reg [9:0] counter;
	/*
	initial begin
		counter <= 10'd0;
	end
	*/
	// State transistion logic
	wire trig;
	assign trig = ( check ^ reset );
	reg trig_dly;
	always @(posedge clk) begin
		trig_dly <= trig;
		if(trig && !trig_dly) begin
			if(reset) begin
				counter <= 10'd0;
			end else begin
				if( !( ~slot[0] & slot[9] & slot[10] ) ) begin
					counter <= counter + 1;
				end
			end
		end
	end
	// One error will always be detected during the break at the start of
	// every frame, which is a false error. So we ignore it by checking if
	// the counter is greater than 1 rather than 0.
	assign error = (counter > 10'd1);
endmodule


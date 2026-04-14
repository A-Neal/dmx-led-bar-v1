// DMX Decoder written in Verilog

module main(
	input		CLK_12MHz,
	input		DMX_INPUT,
	input	[8:0]	DMX_ADDR,
	output	[5:0]	PWM_OUT,
	output		DEBUG_OUT
);
	/*
	// Logic to quantize DMX_INPUT to the clock
	wire dmx_signal;
	reg dmx_first;
	reg dmx_second;
	always @(posedge CLK_12MHz) begin
		dmx_first <= DMX_INPUT;
		dmx_second <= dmx_first;
	end
	assign dmx_signal = dmx_second;
	*/

	wire [9:0] dmx_addr_norm;
	assign dmx_addr_norm[9] = 1'd0;
	assign dmx_addr_norm[8:0] = (9'd511 ^ DMX_ADDR);

	wire [7:0] debug_bus;
	wire debug_wire;
	assign DEBUG_OUT = pwm0_shift_in;
	wire dmx_sync;
	async_synchronizer dmx_synchro(
		.clk(CLK_12MHz),
		.async(DMX_INPUT),
		.sync(dmx_sync)
		);
	wire bd_out;
	assign debug_bus[7] = bd_out;
	break_detector bd(
		.clk(CLK_12MHz),
		.dmx(dmx_sync),
		.out(bd_out)
		);
	wire md_out;
	assign debug_bus[6] = md_out;
	mab_detector md(
		.clk(CLK_12MHz),
		.dmx(dmx_sync),
		.brk(bd_out),
		.out(md_out)
		);
	wire output_enable;
	assign debug_bus[5] = output_enable;
	dmx_timeout dt(
		.clk(CLK_12MHz),
		.rst(md_out),
		.out(output_enable)
		);
	wire bc_out;
	wire bc_slot;
	assign debug_bus[4] = bc_out;
	assign debug_bus[3] = bc_slot;
	byte_clock bc(
		.clk(CLK_12MHz),
		.rst(bd_out),
		.dmx(dmx_sync),
		//.debug(debug_wire),
		.bit_clk(bc_out),
		.slot_end(bc_slot)
		);
	wire [9:0] current_slot;
	slot_counter sc(
		.clk(CLK_12MHz),
		.inc(bc_slot),
		.rst(md_out),
		.slot_num(current_slot)
		);
	wire [10:0] sr_out;
	slot_register sr(
		.clk(bc_out),
		.dmx(dmx_sync),
		.slot(sr_out)
		);
	
	wire b0not0;
	wire bzr_trig;
	assign debug_bus[2] = b0not0;
	assign debug_bus[1] = bzr_trig;
	assign bzr_trig = (current_slot == 10'd1); // Transition from 0-byte to 1-byte
	byte_zero_reg bzr(
		.clk(CLK_12MHz),
		.shift_in(bzr_trig),
		.data_in(sr_out[8:1]),
		.non_zero(b0not0)
		);

	
	wire slot_err;
	assign debug_bus[0] = slot_err;
	slot_error_detector sed(
		.clk(CLK_12MHz),
		.check(bc_slot),
		.slot(sr_out),
		.reset(md_out),
		.error(slot_err)
		);
	/*
	wire atrig_prime;
	wire [5:0] atrig_out;
	assign atrig_prime = (current_slot == dmx_addr_norm+1);
	address_trigger atrig(
		.reset(bd_out),
		.prime(atrig_prime),
		.inc(bc_slot),
		.slot_end(bc_slot),
		.trig_out(atrig_out)
		);
	*/

	// The DMX address is set with 9 bits, but is a number between 1 and
	// 512, so 1 is added to offset the 0-511 discrepancy.
	// The PWM pre-registers are triggered on the start of the next slot
	// address which is the end of the target address, so 1 is added to
	// accomodate this offset.
	// Altogether, 2 is added as the sum of both offsets.
	// A high signal is an un-jumped bit, so the address is inverted to
	// make jumped bits 1, and un-jumped bits 0.
	
	wire pwm0trig;
	assign pwm0trig = (current_slot == dmx_addr_norm+2);
	//assign pwm0trig = atrig_out[0];
	wire [7:0] pwm0_pre;
	wire pwm0_shift_in;
	pwm_pre_reg pwm0pre_reg(
		.clk(CLK_12MHz),
		.shift_in(pwm0trig),
		.shift_out_trig(bd_out),
		.data_in(sr_out[8:1]),
		.error(slot_err),
		.b0not0(b0not0),
		.reset(md_out),
		.data_out(pwm0_pre),
		.shift_out(pwm0_shift_in)
		);
	pwm_controller pwm0(
		.enable(output_enable),
		.clk(CLK_12MHz),
		.shift_in(pwm0_shift_in),
		.byte_in(pwm0_pre),
		.pwm(PWM_OUT[0])
		);
	wire pwm1trig;
	assign pwm1trig = (current_slot == dmx_addr_norm+3);
	//assign pwm1trig = atrig_out[1];
	wire [7:0] pwm1_pre;
	wire pwm1_shift_in;
	pwm_pre_reg pwm1pre_reg(
		.clk(CLK_12MHz),
		.shift_in(pwm1trig),
		.shift_out_trig(bd_out),
		.data_in(sr_out[8:1]),
		.error(slot_err),
		.b0not0(b0not0),
		.reset(md_out),
		.data_out(pwm1_pre),
		.shift_out(pwm1_shift_in)
		);
	pwm_controller pwm1(
		.enable(output_enable),
		.clk(CLK_12MHz),
		.shift_in(pwm1_shift_in),
		.byte_in(pwm1_pre),
		.pwm(PWM_OUT[1])
		);
	wire pwm2trig;
	assign pwm2trig = (current_slot == dmx_addr_norm+4);
	//assign pwm2trig = atrig_out[2];
	wire [7:0] pwm2_pre;
	wire pwm2_shift_in;
	pwm_pre_reg pwm2pre_reg(
		.clk(CLK_12MHz),
		.shift_in(pwm2trig),
		.shift_out_trig(bd_out),
		.data_in(sr_out[8:1]),
		.error(slot_err),
		.b0not0(b0not0),
		.reset(md_out),
		.data_out(pwm2_pre),
		.shift_out(pwm2_shift_in)
		);
	pwm_controller pwm2(
		.enable(output_enable),
		.clk(CLK_12MHz),
		.shift_in(pwm2_shift_in),
		.byte_in(pwm2_pre),
		.pwm(PWM_OUT[2])
		);
	wire pwm3trig;
	assign pwm3trig = (current_slot == dmx_addr_norm+5);
	//assign pwm3trig = atrig_out[3];
	wire [7:0] pwm3_pre;
	wire pwm3_shift_in;
	pwm_pre_reg pwm3pre_reg(
		.clk(CLK_12MHz),
		.shift_in(pwm3trig),
		.shift_out_trig(bd_out),
		.data_in(sr_out[8:1]),
		.error(slot_err),
		.b0not0(b0not0),
		.reset(md_out),
		.data_out(pwm3_pre),
		.shift_out(pwm3_shift_in)
		);
	pwm_controller pwm3(
		.enable(output_enable),
		.clk(CLK_12MHz),
		.shift_in(pwm3_shift_in),
		.byte_in(pwm3_pre),
		.pwm(PWM_OUT[3])
		);
	wire pwm4trig;
	assign pwm4trig = (current_slot == dmx_addr_norm+6);
	//assign pwm4trig = atrig_out[4];
	wire [7:0] pwm4_pre;
	wire pwm4_shift_in;
	pwm_pre_reg pwm4pre_reg(
		.clk(CLK_12MHz),
		.shift_in(pwm4trig),
		.shift_out_trig(bd_out),
		.data_in(sr_out[8:1]),
		.error(slot_err),
		.b0not0(b0not0),
		.reset(md_out),
		.data_out(pwm4_pre),
		.shift_out(pwm4_shift_in)
		);
	pwm_controller pwm4(
		.enable(output_enable),
		.clk(CLK_12MHz),
		.shift_in(pwm4_shift_in),
		.byte_in(pwm4_pre),
		.pwm(PWM_OUT[4])
		);
	wire pwm5trig;
	assign pwm5trig = (current_slot == dmx_addr_norm+7);
	//assign pwm5trig = atrig_out[5];
	wire [7:0] pwm5_pre;
	wire pwm5_shift_in;
	pwm_pre_reg pwm5pre_reg(
		.clk(CLK_12MHz),
		.shift_in(pwm5trig),
		.shift_out_trig(bd_out),
		.data_in(sr_out[8:1]),
		.error(slot_err),
		.b0not0(b0not0),
		.reset(md_out),
		.data_out(pwm5_pre),
		.shift_out(pwm5_shift_in)
		);
	pwm_controller pwm5(
		.enable(output_enable),
		.clk(CLK_12MHz),
		.shift_in(pwm5_shift_in),
		.byte_in(pwm5_pre),
		.pwm(PWM_OUT[5])
		);
	
	serial_debug_report sdr(
		.clk(CLK_12MHz),
		.in(debug_bus),
		.out(debug_wire)
	);

endmodule

module us_pulse(
	input		in,
	input		clk,
	output		out
	);
	reg inreg;
	reg state;
	reg [3:0] counter;
	//initial begin
		//counter <= 4'd0;
		//out <= 1'b0;
	//end
	//wire trig;
	//assign trig = (clk ^ in);
	always @(posedge clk) begin
		inreg <= in;
	end
	always @(posedge clk) begin
		if(inreg) begin
			state <= 1'b1;
		end else if(counter > 11) begin
			state <= 1'b0;
		end
	end
	always @(posedge clk) begin
		if(state) begin
			counter <= counter + 1;
		end else begin
			counter <= 4'd0;
		end
	end
	assign out = state;
endmodule

module break_detector(
	input	clk,
	input	dmx,
	output	out
	);
	reg [1:0] state;
	reg [10:0] break_timer;
	/*
	initial begin
		break_timer <= 11'd0;
	end
	*/
	wire detected;
	always @(posedge clk) begin
		if(!dmx) begin
			break_timer <= break_timer + 1;
			if(break_timer > 11'd1056) begin
				break_timer <= 11'd0;
			end
		end else begin
			break_timer <= 11'd0;
		end
	end
	assign detected = (break_timer == 11'd1056); // 88 microseconds
	us_pulse pulse(
		.in(detected),
		.clk(clk),
		.out(out)
		);
endmodule

module mab_detector(
	input		clk,
	input		dmx,
	input		brk,
	output		out
	);
	localparam IDLE = 2'b00;
	localparam PRIMED = 2'b01;
	localparam COUNTING = 2'b10;
	localparam DONE = 2'b11;
	reg [6:0] counter;
	reg [1:0] state;
	reg brkreg;
	wire detected;
	/*
	initial begin
		counter <= 7'd0;
		state <= IDLE;
	end
	*/
	//wire trig;
	//assign trig = (clk ^ brk);
	always @(posedge clk) begin
		brkreg <= brk;
	end
	always @(posedge clk) begin
		if(brkreg) begin
			state <= PRIMED;
		end else if(state == PRIMED) begin
			if(dmx) begin
				state <= COUNTING;
			end
		end else if(state == COUNTING) begin
			if(!dmx) begin
				state <= IDLE;
			end else if(counter > 7'd95) begin // 8 microseconds - 1 cycle
				state <= DONE;
			end
		end else if(state == DONE) begin
			state <= IDLE;
		end
	end
	always @(posedge clk) begin
		if(state == IDLE) begin
			counter <= 7'd0;
		end else if(state == PRIMED) begin
			counter <= 7'd0;
		end else if(state == COUNTING) begin
			counter <= counter + 1;
		end else if(state == DONE) begin
			counter <= 7'd0;
		end
	end
	assign detected = (state == DONE);
	us_pulse pulse(
		.in(detected),
		.clk(clk),
		.out(out)
		);
endmodule


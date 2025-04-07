// stepper.sv
// 3/31/2025
// By: Mikhail Rego
// Description: Top level module for external stepper motor driver
//		v1: Simply, button s1 turns 180-deg cw, button s2 (") ccw.
///////////////////////////////////////////////////////////////////////////////
// Edited: Mikhail R, 4/6/2025
//		v2: you now turn rotary encoder 1, and the stepper moves along with it.
///////////////////////////////////////////////////////////////////////////////

module stepper (
   input logic CLOCK_50, 
   (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) // needed per rotary encoder
   input logic enc1_a, enc1_b,  // Encoder 1 signals      
   input logic s1, //s2,                  // Push-buttons s1(reset_n), s2(use for clamp/unclamp in future edition)
   output logic red, green, blue,      // debugging LEDs
   output logic dir_pulse, step_pulse    // A4988 stepper control pins
);
   logic enc1_cw, enc1_ccw;  // encoder module outputs
   logic cw1, ccw1; // to down-sample encoder.. generally from 4 to 1
	
	// instantiate modules to implement design
	encoder encoder_1 (.clk(CLOCK_50), .a(enc1_a), .b(enc1_b), .cw(enc1_cw), .ccw(enc1_ccw));
	enc_down enc_down_1 (.clk(CLOCK_50), .reset_n(s1), .cw_in(enc1_cw), .ccw_in(enc1_ccw), .cw_out(cw1), .ccw_out(ccw1)) ;
   stepperInterface #(
        .NUM_STEPS(1), // 1 => 1.8 degrees, for max o/p resolution... 5 for larger steps
        .PULSE_LENGTH(50000) // 50,000/50e6 = 0.001 s or 1ms (for 2ms pulse total)... inverse of motor speed
    ) stepperInterface_inst (.CLOCK_50(CLOCK_50), .cw(cw1), .ccw(ccw1), .reset_n(s1), .red(red), .green(green), .blue(blue), .dir(dir_pulse), .step(step_pulse));
	
endmodule

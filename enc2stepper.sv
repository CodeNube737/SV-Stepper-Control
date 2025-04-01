// enc2stepper.sv
// 3/31/2025
// By: Mikhail Rego
// Description: button s1 turns 180-deg cw, button s2 (") ccw.
//		Signals are output to A4988 (stepper driver) pins Direction and Step
/////////////////////////////////////////////////////////////////////////////

module enc2stepper (
input logic cw, ccw,
input logic clk,
output logic step, dir
);

// has 3 states: idle, cw, and ccw

// debounce the s1, s2 inputs (or this can be done in another external module)

// if prev idle && s1, o/p to turn stepper 180 cw, once only

// if prev idle && sw2 o/p to turn stepper 180 ccw, once only

endmodule


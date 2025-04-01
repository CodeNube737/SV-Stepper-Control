// stepper.sv
// 3/31/2025
// By: Mikhail Rego
// Description: Top level module for external stepper motor driver
//		v1: Simply, button s1 turns 180-deg cw, button s2 (") ccw.
/////////////////////////////////////////////////////////////////

module stepper (
   input logic CLOCK_50,       
   input logic s1, s2,          // Push-buttons s1(reset_n), s2(obsolete)
   output logic red, green, blue, // DM LEDs
);

// intermediate logics

// instantiate modules to implement design

endmodule

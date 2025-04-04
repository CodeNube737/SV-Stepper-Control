// stepper.sv
// 3/31/2025
// By: Mikhail Rego
// Description: Top level module for external stepper motor driver
//		v1: Simply, button s1 turns 180-deg cw, button s2 (") ccw.
/////////////////////////////////////////////////////////////////

module stepper (
   input logic CLOCK_50,       
   input logic s1, s2,                  // Push-buttons s1(cw-180), s2(ccw-180)
   output logic red, green, blue,      // debugging LEDs
   output logic dir_pulse, step_pulse    // A4988 stepper control pins
);
   // instantiate modules to implement design
   enc2stepper enc2stepper_inst (.CLOCK_50(CLOCK_50), .s1(s1), .s2(s2), .red(red), .green(green), .blue(blue), .dir(dir_pulse), .step(step_pulse));

endmodule









    // also, make a external module to debounce the s1, s2 inputs 
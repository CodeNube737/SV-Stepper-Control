// enc2stepper.sv
// 3/31/2025
// By: Mikhail Rego
// Description: Button s1 turns 180-deg CW, s2 turns 180-deg CCW.
//              Signals output to A4988 (stepper driver): DIR, STEP
//              DIR = 1 for CW, 0 for CCW
//              STEP = 1ms pulse (50000 cycles high, 50000 low at 50MHz)
/////////////////////////////////////////////////////////////////////////////

module enc2stepper (
    input  logic CLOCK_50,
    input  logic s1, s2,               // Debounced buttons, ACTIVE LOW, -> !s1, !s2
    output logic red, green, blue,     // DM LEDs
    output logic dir, step             // A4988 stepper control pins
);
    // === Parameters ===
    parameter int NUM_STEPS  = 100;     // 180 degrees
    parameter int PULSE_LENGTH = 50000;   // 50,000 / 50e6 = 0.001 s or 1ms (for 2ms pulse total)

    // === FSM ===
    typedef enum logic [1:0] {READY, CW, CCW, IDLE} state_t;
    state_t state, next_state;

    // === Internal Registers ===
    logic [7:0]   step_count;        // Can use [8:0] to avoid truncation
    logic [15:0]  pulseLength_counter;
    logic         step_toggle;

    // === FSM Sequential Logic ===
    always_ff @(posedge CLOCK_50) begin
        if ( ((!(!s1||!s2)) || (state == READY))&&(next_state != IDLE) )
            state <= next_state; //
    end

    // === FSM Next-State Logic ===
    always_comb begin // Pure case-driven FSM: every path assigns next_state
        /*next_state = state; <-- THIS STUPID LINE!! */
        case (state)
            READY: begin
                if (!s1)
                    next_state = CW;
                else if (!s2)
                    next_state = CCW;
                else
                    next_state = READY;
            end

            CW, CCW: begin
                if (step_count >= NUM_STEPS)
                    next_state = READY;
                else
                    next_state = IDLE; // Hold until done
            end

            default: next_state = READY; // Safety fallback
        endcase
    end


    // === Direction Control ===
    always_ff @(posedge CLOCK_50) begin
        if (state == CW)
            dir <= 1'b1;
        else if (state == CCW)
            dir <= 1'b0;
    end

    // === Step Pulse Generator ===
    always_ff @(posedge CLOCK_50) begin
        if ((state == CW || state == CCW) && (next_state != READY)) begin 
            // Toggle at the start of the cycle
            if (pulseLength_counter == 0)
                step_toggle <= ~step_toggle;
            // At end of half-cycle
            if (pulseLength_counter >= PULSE_LENGTH) begin
                pulseLength_counter <= 0;
                // Count step only at end of LOW cycle (HI then LOW)
                if (step_toggle == 0)
                    step_count <= step_count + 1;
            end else
                pulseLength_counter <= pulseLength_counter + 1;
        end else begin
            // Default case (READY or ending)
            step_count          <= 0;
            pulseLength_counter <= 0;
            step_toggle         <= 0;
        end
    end

    assign step = step_toggle;

    // === LED Debug ===
    assign red   = (state == CW);
    assign green = (state == CCW);
    assign blue  = (state == READY);
	 // no led means state = IDLE... usually the user is pressing the button for too long

endmodule

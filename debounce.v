module debounce #(
    parameter ClockFrequency = 50000000, // Clock frequency in Hz
    parameter DebounceTimeMs = 20        // Debounce time in milliseconds
) (
    input Clk,           // Clock signal
    input nRst,          // Active-low reset signal
    input ButtonIn,      // Raw button input (active low)
    output reg ButtonOut // Debounced button output (active low)
);

    localparam CounterMax = (ClockFrequency / 1000) * DebounceTimeMs;

    reg [31:0] counter;
    reg stable_state;

    always @(posedge Clk or negedge nRst) begin
        if (!nRst) begin
            counter <= 0;
            stable_state <= 1'b1; // Default to unpressed (active high for active-low button)
            ButtonOut <= 1'b1;    // Default to unpressed
        end else begin
            if (ButtonIn == stable_state) begin
                // Button state remains stable
                if (counter < CounterMax) begin
                    counter <= counter + 1;
                end else begin
                    ButtonOut <= ButtonIn; // Update debounced output
                end
            end else begin
                // Button state changes, reset counter
                counter <= 0;
                stable_state <= ButtonIn;
            end
        end
    end

endmodule

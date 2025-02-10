module edge_detector (
    input Clk,         // Clock signal
    input nRst,        // Active-low reset signal
    input SignalIn,    // Input signal (debounced button)
    output reg PulseOut // Single pulse output
);

    reg SignalIn_d; // Delayed version of the input signal

    always @(posedge Clk or negedge nRst) begin
        if (!nRst) begin
            SignalIn_d <= 1'b1; // Default high for active-low button
            PulseOut <= 1'b0;
        end else begin
            SignalIn_d <= SignalIn;
            PulseOut <= (~SignalIn) & SignalIn_d; // Falling edge detection
        end
    end

endmodule

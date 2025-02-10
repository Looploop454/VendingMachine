module VendingMachine #(
    parameter ClockFrequency = 50000000 // Clock Frequency 
) (
    input Clk,               
    input nRst,              
    input button1,  //Buttons for input           
    input button2,           
    input switch,    //Dud switch to act as coins being inputted         
    output reg led1, //LED simulates the output signal        
    output reg led2,         
    output [6:0] seg1, //Display out      
    output [6:0] seg2,       
    output [6:0] seg3,       
    output [6:0] seg4        
);

    // Parameters
    parameter COST = 100;             // Cost of supposed items
    parameter CREDIT_INCREMENT = 5;   // Dud value for coins, when a coin acceptor is attached, this pin will be treated as the coin acceptor

    // Internal Registers
    reg [31:0] Ticks_Internal;        // Counter for timing
    reg [15:0] credits;               // Credit counter

    reg [31:0] led1_timer;            // Timer for LED1
    reg [31:0] led2_timer;            // Timer for LED2

    // Outputs for 7-segment displays
    wire [3:0] thousands, hundreds, tens, ones;

    // Debounced button signals
    wire debounced_button1, debounced_button2;

    // Button press edge detection outputs
    wire button1_pressed, button2_pressed;

    // Declaring debounce modules
    debounce #(
        .ClockFrequency(ClockFrequency),
        .DebounceTimeMs(20)
    ) debounce_button1 (
        .Clk(Clk),
        .nRst(nRst),
        .ButtonIn(button1),
        .ButtonOut(debounced_button1)
    );

    debounce #(
        .ClockFrequency(ClockFrequency),
        .DebounceTimeMs(20)
    ) debounce_button2 (
        .Clk(Clk),
        .nRst(nRst),
        .ButtonIn(button2),
        .ButtonOut(debounced_button2)
    );

    // Declaring edge detectors
    edge_detector edge_detector_button1 (
        .Clk(Clk),
        .nRst(nRst),
        .SignalIn(debounced_button1),
        .PulseOut(button1_pressed)
    );

    edge_detector edge_detector_button2 (
        .Clk(Clk),
        .nRst(nRst),
        .SignalIn(debounced_button2),
        .PulseOut(button2_pressed)
    );

    // Declaring 7 seg displays
    SevenSegDecoder seven_seg1 (
        .digit(ones),
        .segments(seg1)
    );

    SevenSegDecoder seven_seg2 (
        .digit(tens),
        .segments(seg2)
    );

    SevenSegDecoder seven_seg3 (
        .digit(hundreds),
        .segments(seg3)
    );

    SevenSegDecoder seven_seg4 (
        .digit(thousands),
        .segments(seg4)
    );

    // Break credits into BCD digits
    assign thousands = (credits >= 1000) ? (credits / 1000) % 10 : 0;
    assign hundreds  = (credits >= 100)  ? (credits / 100) % 10  : 0;
    assign tens      = (credits >= 10)   ? (credits / 10) % 10   : 0;
    assign ones      = credits % 10;

    // Main Process: Clock-driven Logic
    always @(posedge Clk or negedge nRst) begin
        if (!nRst) begin
            // Reset logic
            Ticks_Internal <= 0;
            credits <= 16'd0; 
            led1 <= 0;
            led2 <= 0;
            led1_timer <= 0;
            led2_timer <= 0;
        end else begin
            // Limit credits under 100 dollars
            if (credits > 9999) 
                credits <= 9999;

            // Timing Logic
            if (Ticks_Internal == ClockFrequency - 1) begin
                Ticks_Internal <= 0;

                // Decrement timers if active
                if (led1_timer > 0) 
                    led1_timer <= led1_timer - 1;

                if (led2_timer > 0) 
                    led2_timer <= led2_timer - 1;

                // Turn off LEDs when timers reach 0
                if (led1_timer == 1) 
                    led1 <= 0;

                if (led2_timer == 1) 
                    led2 <= 0;

                // Add credits when switch is toggled
                if (switch)
                    credits <= credits + CREDIT_INCREMENT;
            end else begin
                Ticks_Internal <= Ticks_Internal + 1;
            end

            // Button1 Logic: Control LED1 timer
            if (button1_pressed) begin
                if (credits >= COST) begin
                    credits <= credits - COST;
                    led1 <= 1;
                    led1_timer <= led1_timer + ClockFrequency; // Add 1 second per press
                end
            end

            // Button2 Logic: Control LED2 timer
            if (button2_pressed) begin
                if (credits >= COST) begin
                    credits <= credits - COST;
                    led2 <= 1;
                    led2_timer <= led2_timer + ClockFrequency; // Add 1 second per press
                end
            end
        end
    end

endmodule

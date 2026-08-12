
module param_reg #(parameter WIDTH = 32) (
    input wire clk,                 // Clock signal
    input wire rst,                 // Asynchronous/Synchronous reset
    input wire clear,               // Flush signal (clears register to 0 during hazards/branches)
    input wire en,                  // Stall enable signal (freezes register value when high)
    input wire [WIDTH-1:0] d,       // Data input
    output reg [WIDTH-1:0] q        // Data output
);

    always @(posedge clk or posedge rst) begin
        if (rst) 
            q <= {WIDTH{1'b0}};     // Reset output to zero
        else if (clear) 
            q <= {WIDTH{1'b0}};     // Flush output to zero
        else if (en) 
            q <= d;                 // Update data normally when not stalled
    end
endmodule

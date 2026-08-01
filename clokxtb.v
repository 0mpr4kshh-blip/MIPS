// ──────────────────────────────────────────────
// Testbench
// ──────────────────────────────────────────────
`timescale 1s / 1ms

module clokx_tb;
    wire [7:0] seconds, minutes;
    reg rst, clk;

    // Clock generation
    initial clk = 0;
    always #0.5 clk = ~clk;   // cleaner than forever inside initial

    // UUT — moved outside the initial blocks (cleaner structure)
    clocki uut (
        .clk(clk),
        .rst(rst),
        .seconds(seconds),
        .minutes(minutes)
    );

    initial begin
        $dumpfile("clokxtb.vcd");
        $dumpvars(0, clokx_tb);

        rst = 1;
        #2;
        rst = 0;

        #3700;  // run for >61 minutes to see minutes roll over (optional)
        $finish;
    end

    // Optional: monitor output in transcript
    initial begin
        $monitor("Time=%0t rst=%b sec=%0d min=%0d",
                  $time, rst, seconds, minutes);
    end
endmodule
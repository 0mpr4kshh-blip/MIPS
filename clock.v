// ──────────────────────────────────────────────
// seconds module
// ──────────────────────────────────────────────
module seconds (clk, rst, seconds, secout);
    input clk, rst;
    output [7:0] seconds;
    output secout;          // now a wire, not reg
    reg [7:0] seconds;

    always @(posedge clk or posedge rst) begin
        if (rst)
            seconds <= 8'b0;
        else if (seconds == 8'd59)
            seconds <= 8'b0;
        else
            seconds <= seconds + 1;
    end

    // Combinational: pulse secout the same cycle seconds hits 59
    assign secout = (seconds == 8'd59);
endmodule


// ──────────────────────────────────────────────
// minutes module
// ──────────────────────────────────────────────
module minutes (clk, rst, sec_clk, minutes, minout);
    input clk, rst, sec_clk;
    output [7:0] minutes;
    output minout;          // wire, same fix as above
    reg [7:0] minutes;

    always @(posedge sec_clk or posedge rst) begin
        if (rst)
            minutes <= 8'b0;
        else if (minutes == 8'd59)
            minutes <= 8'b0;
        else
            minutes <= minutes + 1;
    end

    assign minout = (minutes == 8'd59);
endmodule


// ──────────────────────────────────────────────
// top-level clock module
// ──────────────────────────────────────────────
module clocki (clk, rst, seconds, minutes);
    input clk, rst;
    output [7:0] seconds, minutes;
    wire secout;            // FIX 1: declare the interconnect wire
    wire minout;

    seconds sec_inst (
        .clk(clk),
        .rst(rst),
        .seconds(seconds),  // FIX 2: comma was missing here
        .secout(secout)     // FIX 3: correct port name
    );

    minutes min_inst (
        .clk(clk),
        .rst(rst),
        .sec_clk(secout),
        .minutes(minutes),
        .minout(minout)
    );
endmodule
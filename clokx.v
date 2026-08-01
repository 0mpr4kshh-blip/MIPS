// ──────────────────────────────────────────────
// seconds module
// ──────────────────────────────────────────────
module seconds (clk, rst, seconds, s60);
    input clk, rst;
    output [7:0] seconds;
    output s60;          // now a wire, not reg
    reg [7:0] seconds;

    always @(posedge clk or posedge rst) begin
        if (rst)
            seconds <= 8'b0;
        else if (seconds == 8'd59)
            seconds <= 8'b0;
        else
            seconds <= seconds + 1;
    end

    // Combinational: pulse s60 the same cycle seconds hits 59
    assign s60 = (seconds == 8'd59);
endmodule


// ──────────────────────────────────────────────
// minutes module
// ──────────────────────────────────────────────
module minutes (clk, rst, s60, minutes, minout);
    input clk, rst, s60;
    output [7:0] minutes;
    output m60;          // wire, same fix as above
    reg [7:0] minutes;

    always @(posedge s60 or posedge rst) begin
        if (rst)
            minutes <= 8'b0;
        else if (minutes == 8'd59)
            minutes <= 8'b0;
        else
            minutes <= minutes + 1;
    end

    assign m60 = (minutes == 8'd59);
endmodule


// ──────────────────────────────────────────────
// hours module
// ──────────────────────────────────────────────
module hours (clk, rst, m60, hours, h24);
    input clk, rst, m60;
    output [4:0] hours;
    output h24;          // wire, same fix as above
    reg [4:0] hours;

    always @(posedge m60 or posedge rst) begin
        if (rst)
            hours <= 8'b0;
        else if (hours == 8'd23)
            hours <= 8'b0;
        else
            hours <= hours + 1;
    end

    assign h24 = (hours == 8'd23);
endmodule

module days (clk, rst, h24, days, mnend, month);
    input clk, rst, h24, month;
    output [4:0] days;
    output mnend;          // wire, same fix as above
    reg [4:0] days;

    always @(posedge h24 or posedge rst) begin
        if (rst)
            days <= 8'b0;
        else
        case (days)
        leap_yr && (month == 8'd2) && (days == 8'd28): days <= 8'b0, mnend <= 1;
        !leap_yr && (month == 8'd2) && (days == 8'd27): days <= 8'b0, mnend <= 1;
        (month == 8'd4 || month == 8'd6 || month == 8'd9 || month == 8'd11) && (days == 8'd29): days <= 8'b0, mnend <= 1;
        (month == 8'd1 || month == 8'd3 || month == 8'd5 || month == 8'd7 || month == 8'd8 || month == 8'd10 || month == 8'd12) && (days == 8'd30): days <= 8'b0, mnend <= 1;
        default: days <= days + 1, mnend <= 0;
        endcase
    end

endmodule

module months (clk, rst, mnend, months, mn12);
    input clk, rst, mnend;
    output [3:0] months;
    output mn12;          // wire, same fix as above
    reg [3:0] months = 8'b0;  // initialize to 0

    always @(posedge mnend or posedge rst) begin
        if (rst)
            months <= 8'b0;
        else if (months == 8'd11)
            months <= 8'b0;
        else
            months <= months + 1;
    end

    assign mn12 = (months == 8'd11);
endmodule

module years (clk, rst, mn12, years, yrout);
    input clk, rst, mn12;
    output [7:0] years;
    output yrout;          // wire, same fix as above
    reg [7:0] years;
    reg leap_yr;

    always @(posedge mn12 or posedge rst) begin
        if (rst)
            years <= 8'b0;
        else if (years == 8'd99)
            years <= 8'b0;
        else
            case(years)
            (years % 4) == 0 && (years % 100) != 0 || (years % 400) == 0: leap_yr <= 1;  // simplistic leap year check
            default: leap_yr <= 0;
            endcase
    end

    assign yrout = (years == 8'd99);
endmodule

module memory (clk, rst, addr, data_in, data_out, we);
    input clk, rst, we;
    input [7:0] addr;
    input [7:0] data_in;
    output reg [7:0] data_out;

    reg [7:0] mem_array [255:0];  // 256 bytes of memory

    always @(posedge clk or posedge rst) begin
        if (rst)
            data_out <= 8'b0;  // clear output on reset
        else if (we)
            mem_array[addr] <= data_in;  // write operation
        else
            data_out <= mem_array[addr];  // read operation
    end

module alarm_setup (set_al , rst, hr_al, min_al, alarm_set);
    input set_al, rst;
    output [7:0] hr_al, min_al;
    output [7:0] alarm_set;  // let's say this is a simple 8-bit value for demo
    output [7:0] alarm_enable;  // same here

    // For demo purposes, we'll just set some values after reset
    always @(posedge set_al or posedge rst) begin
        if (rst) begin
            alarm_set <= 8'b0;      // e.g., set to 00:00  // enable the alarm
        end else begin
            // In a real design, these would be set by some user interface logic
            hr_al <= 8'd12;        // example: set to 12:00
            minutes_al <= 8'd0;
            alarm_set <= {hours_al, minutes_al};  // simplistic combination for demo
        end
    end

module alarm (hours, minutes, alarm_set, alarm_out, alarm_enable);
    input [7:0] hours, minutes, alarm_enable;
    input [7:0] alarm_set;  // let's say this is a simple 8-bit value for demo
    output alarm_out;       // wire

    always @(posedge clk or posedge rst) begin
        if (rst)
            alarm_out <= 0;
        else if ({hours, minutes} == alarm_set)  // simplistic check
            alarm_out <= 1;
        else
            alarm_out <= 0;
    end
module tasks (clk, rst, minutes, task_in, task_out);


// ──────────────────────────────────────────────
// top-level clock module
// ──────────────────────────────────────────────
module clocki (clk, rst, seconds, minutes, hours, days, months, years);
    input clk, rst;
    output [7:0] seconds, minutes, hours, days, months, years;
    wire secout;            // FIX 1: declare the interconnect wire
    wire minout;
    wire hrout;
    wire dyout;
    wire mnout;
    wire yrout;

    seconds sec_inst (
        .clk(clk),
        .rst(rst),
        .seconds(seconds),  // FIX 2: comma was missing here
        .s60(s60)     // FIX 3: correct port name
    );

    minutes min_inst (
        .clk(clk),
        .rst(rst),
        .s60(s60),
        .minutes(minutes),
        .m60(m60)
    );
    hours hr_inst (
        .clk(clk),
        .rst(rst),
        .m60(m60),
        .hours(hours),
        .h24(h24)
    );

    days dy_inst (
        .clk(clk),
        .rst(rst),
        .h24(h24),
        .days(days),
        .mnend(mnend),
        .month(months)
    );

    months mn_inst (
        .clk(clk),
        .rst(rst),
        .mnend(mnend),
        .months(months),
        .mn12(mn12)
    );

    years yr_inst (
        .clk(clk),
        .rst(rst),
        .mn12(mn12),
        .years(years),
        .yrout(yrout)
    );


endmodule


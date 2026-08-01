module addertb;
reg a, b, cin;
wire ab, bc, ac;
wire cout, sum;
adder uut (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
);
initial begin
    $dumpfile("addertb.vcd");
    $dumpvars(0, addertb);
    a = 0; b = 0; cin = 0;
    #5 a = 0; b = 0; cin = 0;
    #5 a = 0; b = 1; cin = 0;
    #5 a = 1; b = 1; cin = 1;
    #5 a = 0; b = 0; cin = 1;
end
endmodule

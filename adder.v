module adder (cout, sum, a, b, cin);
input a, b, cin;
output cout, sum;
wire ab, bc, ac;
xor(sum, a, b, cin);
and(ab, a, b);
and(ac, a, cin);
and(bc, cin, b);
or(cout, ab, bc, ac);
endmodule

module mipstb;
reg clkin = 0;
reg [31:0] inst_mem [0:63];
wire [31:0] gpr [0:31];
always #5 clkin = ~clkin;

main uut (
    .clkin(clkin),
    .inst_mem(inst_mem)
);
integer i;

initial begin
    #100;
    $finish;
end
always @(posedge clkin) begin
    $display("PC = %d", uut.pc);
    $display("opcode = %b", uut.opcode);
    $display("rd_ret = %b", uut.rd_ret);
    $display("rdv = %b", uut.rdv);
    $display("\nTime = %0t", $time);

    for (i = 0; i < 31; i = i + 1)
        $display("gpr = %b", uut.gpr[i]);
end

initial begin
    $dumpfile("mipstb.vcd");
    $dumpvars(0, mipstb);
    inst_mem [0] = 32'b00100000000010000000000000000101;
    inst_mem [1] = 32'b00100000000010010000000000001010;
    inst_mem [2] = 32'b00000001000010010101000000100000;
    inst_mem [3] = 32'b00000001001010000101100000100010;
    inst_mem [4] = 32'b00000001000010010101000000100100;
    inst_mem [5] = 32'b00000001000010010101000000100101;
    inst_mem [6] = 32'b00000001000010010101000000100110;
    inst_mem [7] = 32'b00000001000010010101000000101010;
    inst_mem [8] = 32'b00100000000100000000000001100100;
end


endmodule

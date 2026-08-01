module main(clkin, inst_mem, rs, rt);
input clkin;
output reg clk;
output reg [31:0] instruction;
input reg [31:0] inst_mem [0:63];
reg [31:0] pc;
input [25:0] target;
input j_mux;
output reg [4:0] rs;
output reg [4:0] rt;
assign clk = clkin;
wire [31:0] gpr [0:31];

initial begin
    pc = 0;
    instruction = 0;
end


always @(posedge clk) begin
    if (j_mux) begin
        pc <= {pc[31:28], target, 2'b00};
    end else begin
        pc <= pc + 4;
    end
    instruction <= inst_mem[pc[7:2]];
end

assign rs = instruction[25:21];
assign rt = instruction[20:16];

wire [4:0] lw_gpr_addr;
wire [31:0] sw_mem_addr;
wire [4:0] rd_d;
wire [31:0] mem_addr;
wire [31:0] rdv;
wire [4:0] rdv_mem;
wire [31:0] mem_data_in;
wire [31:0] mem_data_out;
wire [4:0] rd_ret;
wire [4:0] rd;
wire [31:0] rsv_gpr;
wire [31:0] rtv_gpr;
wire [31:0] rsv_alu;
wire [31:0] rtv_alu;
wire [25:0] target;
wire j_mux;
wire [5:0] opcode;
wire [5:0] funct;
wire i_mux;
wire [4:0] shamt;

decode_diff decode_diff0 (clk, instruction, target, j_mux, opcode, rd, funct, i_mux,
 rsv_gpr, rtv_gpr, rsv_alu, rtv_alu);
d_buffer d_buffer0(clk, lw_mux, sw_mux2, lw_gpr_addr,
 rd_d, mem_addr, sw_mem_addr, rdv);
memory mem0(clk, mem_addr, mem_data_in, mem_data_out, 
 rdv, lw_mux, sw_mux2);
gp_registers gpr0(clk, rsv_gpr, rtv_gpr, rs, rt, rd, rd_d, rd_ret, rdv,
lw_mux, sw_mux, mem_data_in, mem_data_out, gpr);
alu_exe alu0(clk, rsv_alu, rtv_alu, rd, rd_ret, shamt, funct, rdv, opcode, 
lw_mux, i_mux, sw_mux, mem_addr, lw_gpr_addr);

endmodule

module d_buffer(clk, lw_mux, sw_mux2, lw_gpr_addr,
 rd_d, mem_addr, sw_mem_addr, rdv);
input clk;
input lw_mux;
input sw_mux2;
input [4:0] lw_gpr_addr;
input [31:0] sw_mem_addr;
output reg [4:0] rd_d;
output reg [31:0] mem_addr;
input [31:0] rdv;
output reg [31:0] rdv_mem;


always @(posedge clk) begin

    if (lw_mux) begin
        rd_d <= lw_gpr_addr;
    end else if (sw_mux2) begin
        rdv_mem <= rdv;
        mem_addr <= sw_mem_addr;
    end
end
endmodule

module memory (clk, mem_addr, mem_data_in, mem_data_out, rdv, lw_mux, sw_mux2);
input clk;
input [31:0] rdv;
input lw_mux;
input sw_mux2;
input [31:0] mem_addr;
reg [31:0] memorysp [0:255];
input [31:0] mem_data_in;
output reg [31:0] mem_data_out;

always @(posedge clk) begin
    if (sw_mux2) begin
        memorysp[mem_addr[7:0]] <= mem_data_in;
    end else if (lw_mux) begin
        mem_data_out <= memorysp[mem_addr[7:0]];
    end
end
endmodule

module gp_registers (clk, rsv_gpr, rtv_gpr, rs, rt, rd, rd_d, rd_ret, rdv,
lw_mux, sw_mux, mem_data_in, mem_data_out, gpr);
    integer i;
    input clk;
    input [4:0] rs;
    input [4:0] rt;
    input [4:0] rd_ret;
    input [31:0] rdv;
    input [4:0] rd;
    input [4:0] rd_d;
    output reg [31:0] gpr [0:31];
    output reg [31:0] mem_data_in;
    input [31:0] mem_data_out;
    input lw_mux;
    input sw_mux;
    output reg lw_mux2;
    output reg sw_mux2;
    output reg [31:0] rsv_gpr;
    output reg [31:0] rtv_gpr;

    initial begin 
    for (i = 0; i < 31; i = i + 1)
        gpr[0]<=32'b000000000000000000000000;
    end


    always @(posedge clk) begin
        

        if (lw_mux) begin
            lw_mux2 <= 1;
        end else if (sw_mux) begin
            mem_data_in <= gpr[rd_d];
            sw_mux2 <= 1;
        end

        if (lw_mux2 == 1) begin
            gpr[rd_d] <= mem_data_out;
            lw_mux2 <= 0;
        end
        else if (!lw_mux && !sw_mux) begin
            gpr[rd_ret] <= rdv;
        end
        rsv_gpr <= gpr[rs];
        rtv_gpr <= gpr[rt];
    end


endmodule

module decode_diff(clk, instruction, target, j_mux, opcode, rd, funct, i_mux, rsv_gpr, rtv_gpr, rsv_alu, rtv_alu);
    input clk;
    input [31:0] instruction;
    input [31:0] rsv_gpr;
    input [31:0] rtv_gpr;
    output reg [25:0] target;
    output reg j_mux;
    output reg [5:0] opcode;
    output reg [4:0] rd;
    output reg [5:0] funct;
    output reg [31:0] rsv_alu;
    output reg [31:0] rtv_alu;
    output reg i_mux;

    always @(posedge clk) begin
        opcode <= instruction[31:26];
        if (instruction[31:26] == 6'b000000) begin // R-type instruction
            rd <= instruction[15:11];
            rsv_alu <= rsv_gpr;
            rtv_alu <= rtv_gpr;
            funct <= instruction[5:0];
        end else if (instruction[31:26] == 6'b001000 || instruction[31:26] == 6'b100011 || instruction[31:26] == 6'b101011) begin // I-type instruction
            rd <= instruction[20:16];
            rsv_alu <= rsv_gpr;
            rtv_alu <= {{16{instruction[15]}}, instruction[15:0]};
            i_mux <= 1;
        end else if (instruction[31:26] == 6'b000010 || instruction[31:26] == 6'b000011) begin // J-type instruction
            target <= instruction[25:0];
            j_mux <= 1;
        end
    end
endmodule

module alu_exe(clk, rsv_alu, rtv_alu, rd, rd_ret, shamt, funct, rdv, opcode, lw_mux, i_mux, sw_mux, mem_addr, lw_gpr_addr);
    input clk;
    input [31:0] rsv_alu;
    input [31:0] rtv_alu;
    input [4:0] rd;
    input [4:0] shamt;
    input [5:0] funct;
    input [5:0] opcode;
    input i_mux;
    wire [31:0] rsv;
    wire [31:0] rtv;
    output reg [4:0] rd_ret;
    output reg [31:0] rdv;
    output reg lw_mux;
    output reg sw_mux;
    reg i_check;
    output reg [31:0] mem_addr;
    output reg [4:0] lw_gpr_addr;
    assign rsv = rsv_alu;
    assign rtv = rtv_alu;

    always @(posedge clk) begin
        rd_ret <= rd;
        lw_mux <= 0;
        sw_mux <= 0;
        if (opcode == 6'b000000) begin
            case (funct)
                6'b100000: rdv <= rsv + rtv; // AD
                6'b100010: rdv <= rsv - rtv; // SUB
                6'b100100: rdv <= rsv & rtv; // AND
                6'b100101: rdv <= rsv | rtv; // OR
                6'b101010: rdv <= (rsv < rtv) ? 1 : 0; // SLT
                6'b100001: rdv <= rsv + rtv; // ADDU
                6'b100011: rdv <= rsv - rtv; // SUBU
                6'b100110: rdv <= rsv ^ rtv; // XOR
                6'b100111: rdv <= ~(rsv | rtv); // NOR
                6'b101011: rdv <= (rsv < rtv) ? 1 : 0; // SLTU
                default: rdv <= 0;
            endcase
        end 
        else if (opcode == 6'b001000) begin
            rdv <= rsv + rtv;
        end
        else if (opcode == 6'b100011) begin
            lw_mux <= 1;
        end
        else if (opcode == 6'b101011) begin
            sw_mux <=1;
        end
        end
endmodule

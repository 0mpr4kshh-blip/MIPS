module memory (mem_clk, mem_addr, mem_data_in, mem_data_out, mem_wr_en, mem_rd_en);
input mem_clk;
input [7:0] mem_addr;
input [31:0] mem_data_in;
input mem_wr_en;
input mem_rd_en;
output reg [31:0] mem_data_out;

reg [31:0] memorysp [0:255]; // 256 words of 32 bits each

always @(posedge mem_clk) begin
    if (mem_wr_en) begin
        memorysp[mem_addr] <= mem_data_in;
    end else if (mem_rd_en) begin
        mem_data_out <= memorysp[mem_addr];
    end
end
endmodule

module is_fetch (clk, rst, pc, instruction);
    input clk;
    input rst;
    input [31:0] pc;
    output reg [31:0] instruction;

    // Simple instruction memory: 256 words of 32 bits
    reg [31:0] inst_mem [0:255];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            instruction <= 32'b0; // Reset instruction to 0
        end else begin
            // Fetch instruction from memory using lower 8 bits of pc
            instruction <= inst_mem[pc[7:0]];
        end
    end
endmodule

module gp_registers (clk, rst, rs, rt, rd, write_data, reg_write_en, read_data1, read_data2);
    input clk;
    input rst;
    input [4:0] rs;
    input [4:0] rt;
    input [4:0] rd;
    input [31:0] write_data;
    input reg_write_en;
    output reg [31:0] read_data1;
    output reg [31:0] read_data2;

    reg [31:0] registers [0:31]; // 32 general-purpose registers

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all registers to 0
            integer i;
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (reg_write_en) begin
            // Write data to the specified register
            registers[rd] <= write_data;
        end
    end

    always @(*) begin
        // Read data from the specified registers
        read_data1 = registers[rs];
        read_data2 = registers[rt];
    end

module fetch2(clk, rst, instruction, opcode, rs, rt, rd, shamt, funct, immediate, address);
    input clk;
    input rst;
    input [31:0] instruction;
    output [5:0] opcode;
    output [4:0] rs;
    output [4:0] rt;
    output [4:0] rd;
    output [4:0] shamt;
    output [5:0] funct;
    output [15:0] immediate;
    output [25:0] address;

    reg [5:0] opcode;
    reg [4:0] rs;
    reg [4:0] rt;
    reg [4:0] rd;
    reg [4:0] shamt;
    reg [5:0] funct;
    reg [15:0] immediate;
    reg [25:0] address;

    always @(posedge clk or posedge rst) begin
        opcode <= instruction[31:26];
    end

    always @(posedge clk or posedge rst) begin
        if (opcode == 6'b000000) begin // R-type instruction
            rs <= instruction[25:21];
            rt <= instruction[20:16];
            rd <= instruction[15:11];
            shamt <= instruction[10:6];
            funct <= instruction[5:0];
            rsv <= read_data1;
            rtv <= read_data2;
            r_type(rsv, rtv, rd, shamt, funct);
        end else if (opcode == 6'b001000 || opcode == 6'b001001) begin // I-type instruction
            rs <= instruction[25:21];
            rt <= instruction[20:16];
            immediate <= instruction[15:0];
            itype(rs, rt, immediate);
        end else if (opcode == 6'b000010 || opcode == 6'b000011) begin // J-type instruction
            address <= instruction[25:0];
            j_type(address);
        end


    end
endmodule

module r_type(rs, rt, rd, shamt, funct);
    input [4:0] rsv;
    input [4:0] rtv;
    input [4:0] rd;
    input [4:0] shamt;
    input [5:0] funct;

    always @(posedge clk) begin
        if(funct == 6'b100000) begin

        end else if(funct == 6'b100010) begin // SUB
            // R-type instruction processing logic can be added here
        end else if(funct == 6'b100100) begin // AND
            // R-type instruction processing logic can be added here
        end else if(funct == 6'b100101) begin // OR
            // R-type instruction processing logic can be added here
        end else if(funct == 6'b101010) begin // SLT
            // R-type instruction processing logic can be added here
        end else if(funct == 6'b100001) begin // ADDU
            // R-type instruction processing logic can be added here
        end else if(funct == 6'b100011) begin // SUBU
            // R-type instruction processing logic can be added here
        end else if(funct == 6'b100110) begin // XOR
            // R-type instruction processing logic can be added here
        end else if(funct == 6'b100111) begin // NOR
            // R-type instruction processing logic can be added here
        end else if(funct == 6'b101011) begin // SLTU
            // R-type instruction processing logic can be added here
        end
    end

    

    // R-type instruction processing logic can be added here
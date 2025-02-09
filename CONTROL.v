`timescale 1ns / 1ps
module CONTROL( 
    // ��ɾ��� opcode�� �ص��Ͽ� ALU �� Register ���� ��ȣ�� �����ϴ� ���
    input clk, rst,             // Ŭ�� ��ȣ �� ���� ��ȣ
    input [3:0] Opcode,         // IO ��⿡�� ���� 4��Ʈ opcode
    input [2:0] pst,            // IO ��⿡�� ���� ���� ���� (state)
    output reg [3:0] ALU_Op,    // ALU ���� ������ �����ϴ� 4��Ʈ ��ȣ
    output reg ALU_Src,         // ALU �Է��� �ҽ� ���� ���� ��ȣ
    output reg Reg_Write        // �������� ���� ������ �����ϴ� ��ȣ
    );

    // ��ɾ ���� opcode ����
    parameter NOP = 4'b0000,   // No Operation
              Write = 4'b0001, // Write ����
              Read = 4'b0010,  // Read ����
              Copy = 4'b0011,  // Copy ����
              NOT = 4'b0100,   // Bitwise NOT
              AND = 4'b0101,   // Bitwise AND
              OR = 4'b0110,    // Bitwise OR
              XOR = 4'b0111,   // Bitwise XOR
              NAND = 4'b1000,  // Bitwise NAND
              NOR = 4'b1001,   // Bitwise NOR
              ADD = 4'b1010,   // Addition
              SUB = 4'b1011,   // Subtraction
              ADDI = 4'b1100,  // Add Immediate
              SUBI = 4'b1101,  // Subtract Immediate
              SLL = 4'b1110,   // Shift Left Logical
              SRL = 4'b1111;   // Shift Right Logical
                           
    // �ʱ� �� ����
    initial begin
        ALU_Op <= 4'b0000;    // �⺻ ALU ���� ����
        Reg_Write <= 1'b0;    // �⺻������ �������� ���� ��Ȱ��ȭ
        ALU_Src <= 1'b0;      // �⺻������ ALU�� �� ��° �Է� �ҽ��� ��������
    end

    always @ (posedge clk) begin
        if (rst) begin
            // ���� �� ��� ���� ��ȣ �ʱ�ȭ
            ALU_Op <= 4'b0000;
            Reg_Write <= 1'b0;
            ALU_Src <= 1'b0; 
        end else begin
            if (pst == 3'b001) begin
                // ���°� 1�� �� Opcode�� �ص��Ͽ� ���� ��ȣ ����
                case (Opcode)
                    NOP:  {ALU_Op, Reg_Write, ALU_Src} <= {NOP, 1'b0, 1'b0};    // No Operation
                    Write: {ALU_Op, Reg_Write, ALU_Src} <= {Write, 1'b1, 1'b1}; // Write ����
                    Read:  {ALU_Op, Reg_Write, ALU_Src} <= {Read, 1'b0, 1'b0};  // Read ���� (���� ����)
                    Copy:  {ALU_Op, Reg_Write, ALU_Src} <= {Copy, 1'b1, 1'b0};  // Copy ����
                    NOT:   {ALU_Op, Reg_Write, ALU_Src} <= {NOT, 1'b1, 1'b0};   // Bitwise NOT
                    AND:   {ALU_Op, Reg_Write, ALU_Src} <= {AND, 1'b1, 1'b0};   // Bitwise AND
                    OR:    {ALU_Op, Reg_Write, ALU_Src} <= {OR, 1'b1, 1'b0};    // Bitwise OR
                    XOR:   {ALU_Op, Reg_Write, ALU_Src} <= {XOR, 1'b1, 1'b0};   // Bitwise XOR
                    NAND:  {ALU_Op, Reg_Write, ALU_Src} <= {NAND, 1'b1, 1'b0};  // Bitwise NAND
                    NOR:   {ALU_Op, Reg_Write, ALU_Src} <= {NOR, 1'b1, 1'b0};   // Bitwise NOR
                    ADD:   {ALU_Op, Reg_Write, ALU_Src} <= {ADD, 1'b1, 1'b0};   // Addition
                    SUB:   {ALU_Op, Reg_Write, ALU_Src} <= {SUB, 1'b1, 1'b0};   // Subtraction
                    ADDI:  {ALU_Op, Reg_Write, ALU_Src} <= {ADDI, 1'b1, 1'b1};  // Add Immediate (I-Type)
                    SUBI:  {ALU_Op, Reg_Write, ALU_Src} <= {SUBI, 1'b1, 1'b1};  // Subtract Immediate (I-Type)
                    SLL:   {ALU_Op, Reg_Write, ALU_Src} <= {SLL, 1'b1, 1'b1};   // Shift Left Logical (I-Type)
                    SRL:   {ALU_Op, Reg_Write, ALU_Src} <= {SRL, 1'b1, 1'b1};   // Shift Right Logical (I-Type)
                endcase
            end
        end
    end
endmodule

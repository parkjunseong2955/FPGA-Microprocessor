`timescale 1ns / 1ps
module CONTROL( 
    // 명령어의 opcode를 해독하여 ALU 및 Register 제어 신호를 생성하는 모듈
    input clk, rst,             // 클록 신호 및 리셋 신호
    input [3:0] Opcode,         // IO 모듈에서 받은 4비트 opcode
    input [2:0] pst,            // IO 모듈에서 받은 현재 상태 (state)
    output reg [3:0] ALU_Op,    // ALU 연산 동작을 제어하는 4비트 신호
    output reg ALU_Src,         // ALU 입력의 소스 선택 제어 신호
    output reg Reg_Write        // 레지스터 쓰기 동작을 제어하는 신호
    );

    // 명령어에 대한 opcode 정의
    parameter NOP = 4'b0000,   // No Operation
              Write = 4'b0001, // Write 동작
              Read = 4'b0010,  // Read 동작
              Copy = 4'b0011,  // Copy 동작
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
                           
    // 초기 값 설정
    initial begin
        ALU_Op <= 4'b0000;    // 기본 ALU 연산 없음
        Reg_Write <= 1'b0;    // 기본적으로 레지스터 쓰기 비활성화
        ALU_Src <= 1'b0;      // 기본적으로 ALU의 두 번째 입력 소스는 레지스터
    end

    always @ (posedge clk) begin
        if (rst) begin
            // 리셋 시 모든 제어 신호 초기화
            ALU_Op <= 4'b0000;
            Reg_Write <= 1'b0;
            ALU_Src <= 1'b0; 
        end else begin
            if (pst == 3'b001) begin
                // 상태가 1일 때 Opcode를 해독하여 제어 신호 설정
                case (Opcode)
                    NOP:  {ALU_Op, Reg_Write, ALU_Src} <= {NOP, 1'b0, 1'b0};    // No Operation
                    Write: {ALU_Op, Reg_Write, ALU_Src} <= {Write, 1'b1, 1'b1}; // Write 동작
                    Read:  {ALU_Op, Reg_Write, ALU_Src} <= {Read, 1'b0, 1'b0};  // Read 동작 (쓰기 없음)
                    Copy:  {ALU_Op, Reg_Write, ALU_Src} <= {Copy, 1'b1, 1'b0};  // Copy 동작
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

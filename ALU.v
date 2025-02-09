`timescale 1ns / 1ps

module ALU(
    input clk, rst,                 // clock, reset 
    input [3:0] ALU_Op,             // ALU ���� ���� control
    input [3:0] Rd1toALU, Rd2toALU, // register �ܰ迡�� �ּҿ� ����ִ� ���� ��ȯ�Ͽ� ������ ���� 
    input [2:0] pst,              // present state
    output reg [3:0] ALU_Result,    // ALU ���� result
    output reg flowcheck,            // underflow or overflow ��Ÿ���� ���� 
    output reg overflow,                  // overflow detect
    output reg underflow                   // underflow detect
    );
    
    wire [3:0] in1, in2;    // ALU�� inputs 
    reg [4:0] REG_ADD_SUB;  // add, substract ��� 5bit�� �� �� ������ ����Ͽ� �ӽ÷� ���� ����� ����

    // 4bit opcode parameter ���� 
    parameter NOP = 4'b0000,  // none opcode  
              Write = 4'b0001, // write
              Read = 4'b0010, // read
              Copy = 4'b0011, // copy
              NOT = 4'b0100, // not
              AND = 4'b0101, // and
              OR = 4'b0110, // or
              XOR = 4'b0111, // xor
              NAND = 4'b1000, // nand
              NOR = 4'b1001, // nor
              ADD = 4'b1010, // add
              SUB = 4'b1011, // sub
              ADDI = 4'b1100, // addi
              SUBI = 4'b1101, // subi
              SLL = 4'b1110,    // shift left logical
              SRL = 4'b1111;    // shift right logical
              
        
    assign in1 = (pst >= 3'b100) ? Rd1toALU : 3'B000; // present state�� 3 �̻��̸�, Rd1toALU �� in1�� ����, �ƴϸ� 0
    assign in2 = (pst >= 3'b100) ? Rd2toALU : 3'B000; // present state 3 �̻��̸�, Rd2toALU �� in2�� ����, �ƴϸ� 0
    
        initial begin   // �ʱⰪ
            ALU_Result <= 4'b0000;
            flowcheck <= 1'b0;
        end   
              
    always @ (posedge clk) // posedge trigger ����
    begin
        if(rst) // reset = 1
        begin
            ALU_Result <= 4'b0000;      // ALU_Result, REG_ADD_SUB, overflow = 0���� �ʱ�ȭ
            REG_ADD_SUB <= 5'b00000; 
            overflow <= 1'b0; 
        end
        else    // reset = 0
        begin
            flowcheck <= 1'b0; // over or underflow detect -> �ʱ�ȭ
            overflow <= 1'b0;       // overflow detect -> �ʱ�ȭ 
            underflow <= 1'b0;       // underflow detect -> �ʱ�ȭ 
            case(ALU_Op)      // ALU Opcode�� ���� ����  
                    NOP : begin
                             ALU_Result <= ALU_Result; // none opcode
                          end
                    Write : begin
                              ALU_Result <= in2;       // Rd2�� �ִ� data�� write�ϰ� ���
                            end
                    Read : begin
                              ALU_Result <= in1;       // Rd1�� �ִ� data�� read�ϰ� ���
                           end
                    Copy : begin
                              ALU_Result <= in1;       // Rd1�� �ִ� data�� copy�ϰ�  ���
                           end
                    NOT : begin
                              ALU_Result <= ~in1;      // Rd1�� �ִ� data�� NOT ������ ��ģ �� ���
                          end
                    AND : begin
                             ALU_Result <= in1 & in2;  // Rd1�� Rd2�� �ִ� data�� AND ������ ��ģ �� ���
                          end
                    OR : begin
                            ALU_Result <= in1 | in2;   // Rd1�� Rd2�� �ִ� data�� OR ������ ��ģ �� ���
                          end
                    XOR : begin
                             ALU_Result <= in1 ^ in2;   // Rd1�� Rd2�� �ִ� data�� XOR ������ ��ģ �� ���
                          end
                    NAND : begin
                              ALU_Result <= ~(in1 & in2);   // Rd1�� Rd2�� �ִ� data�� NAND ������ ��ģ �� ���
                           end
                    NOR : begin
                            ALU_Result <= ~(in1 | in2);      // Rd1�� Rd2�� �ִ� data�� NOR ������ ��ģ �� ���
                         end
                    ADD : begin                             // ADD ���� �� ����(��ȣ ���)
                            if(in1[3] ^ in2[3])             // ��ȣ�� �ٸ� ���
                            begin
                                ALU_Result <= in1 + in2;    // overflow detect x, add
                            end
                            else                            // ��ȣ�� ���� ���
                            begin
                                REG_ADD_SUB <= in1 + in2;   // overflow detect�� ���� �ϱ� ���� ���� ������ �� �� ������ 5bit �������Ϳ� ����
                                if(in1[3] == 1'b1)          // ���� + ������ ���
                                begin
                                    if(REG_ADD_SUB[4] == 1'b1)      // -8 ���ϸ�(MSB = 1) underflow detect 
                                    begin
                                        ALU_Result <= ALU_Result;   // �״�� ���� �Ϸ�
                                        flowcheck <= 1'b1;           // flow detect - underflow
                                        overflow <= 1'b0;
                                        underflow <= 1'b1;                 // underflow detect
                                    end
                                    else                            // undeflow �߻� X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // ���� ��� ������ ���� 4bit ��� 
                                    end
                               end
                               else if(in1[3] == 1'b0)              // ��� + ���
                               begin
                                    if(REG_ADD_SUB[3] == 1'b1)      // 7(1000)�̻��̸�, overflow �߻�
                                    begin
                                        ALU_Result <= ALU_Result;   // �״�� ���� �Ϸ�
                                        flowcheck <= 1'b1;           // flow detect - overflow
                                        overflow <= 1'b1;                 // overflow detect
                                        underflow <= 1'b0;
                                    end
                                    else                            // overflow �߻� X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // ���� ��� ������ ���� 4bit ��� 
                                    end
                                end
                             end 
                          end
                          
                    // ADDI ���� ���� ADD�� ����
                    ADDI : begin                            // ADDI ���� �� ����(��ȣ ���)
                            if(in1[3] ^ in2[3])             // // ��ȣ�� �ٸ� ���
                            begin
                                ALU_Result <= in1 + in2;    // overflow detect x, add
                            end
                            else                            // ��ȣ�� ���� ���
                            begin
                                REG_ADD_SUB <= in1 + in2;   // overflow detect�� ���� �ϱ� ���� ���� ������ �� �� ������ 5bit �������Ϳ� ����
                                if(in1[3] == 1'b1)          // ���� + ����
                                begin
                                    if(REG_ADD_SUB[4] == 1'b1)      // -8 ���ϸ�(MSB = 1) underflow detect 
                                    begin
                                        ALU_Result <= ALU_Result;   // �״�� ���� �Ϸ�
                                        flowcheck <= 1'b1;           // flow detect - underflow
                                        overflow <= 1'b0;
                                        underflow <= 1'b1;                 // underflow detect 
                                    end
                                    else                            // undeflow �߻� X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // ���� ��� ������ ���� 4bit ��� 
                                    end
                               end
                               else if(in1[3] == 1'b0)              // ��� + ���
                               begin
                                    if(REG_ADD_SUB[3] == 1'b1)      // 7(1000)�̻��̸�, overflow �߻�
                                    begin
                                        ALU_Result <= ALU_Result;   // �״�� ���� �Ϸ�
                                        flowcheck <= 1'b1;           // flow detect - overflow
                                        overflow <= 1'b1;                 // overflow detect
                                        underflow <= 1'b0;
                                    end
                                    else                            // overflow �߻� X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // ���� ��� ������ ���� 4bit ��� 
                                    end
                                end
                             end 
                          end
                    SUB : begin                             // SUB ���� �� ����(��ȣ ���)
                            if(in1[3] ^ in2[3])             // ��ȣ�� �ٸ� ���                        
                            begin
                                REG_ADD_SUB <= {1'b0, in1} + {1'b0, (~in2 + 1'b1)};  // overflow detect�� ���� �ϱ� ���� ���� ������ �� �� ������ 5bit �������Ϳ� ����
                                                                                     // 2���� �Է��� 0���� MSBȮ��, �����̹Ƿ� in2�� 2�� ������ ���� �� ���� ���� 
                                if(in1[3] == 1'b1)           // ���� - ���
                                begin
                                    if(REG_ADD_SUB[4] ^ REG_ADD_SUB[3])     // ���� ����� MSB�� ���� 1bit�� ��ȣ�� �ٸ� -> underflow �߻�
                                    begin
                                        ALU_Result <= ALU_Result;           // �״�� ���� �Ϸ�
                                        flowcheck <= 1'b1;                   // flow detect - underflow
                                        overflow <= 1'b0;
                                        underflow <= 1'b1;                         // underflow detect
                                    end
                                    else                    // underflow �߻� X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // ���� ��� ������ ���� 4bit ��� 
                                    end
                                end
                                else if(in1[3] == 1'b0)        // ��� - ���� 
                                begin
                                    if(REG_ADD_SUB[3] == 1'b1) // 7(1000)�̻��̸�, overflow �߻�
                                    begin
                                        ALU_Result <= 4'b0111;
                                        flowcheck <= 1'b1; // flow detect - overflow
                                        overflow <= 1'b1; // overflow detect
                                        underflow <= 1'b0;
                                    end
                                    else // overflow �߻� X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // ���� ��� ������ ���� 4bit ��� 
                                    end
                                end
                            end
                            else            // �� ���� ��ȣ�� ���� ���, underflow �߻� X
                            begin
                                ALU_Result <= in1 + (~in2 + 1'b1);  // in2�� �� 2�� ���� ���� ��, ���� ���� -> ���� ��� ALU_Result�� ����
                            end
                         end
                     // SUBI ���� ���� SUB�� ���� 
                    SUBI : begin                            // SUB ���� �� ����(��ȣ ���)
                            if(in1[3] ^ in2[3])             // ��ȣ�� �ٸ� ���                             
                            begin
                                REG_ADD_SUB <= {1'b0, in1} + {1'b0, (~in2 + 1'b1)};  // overflow detect�� ���� �ϱ� ���� ���� ������ �� �� ������ 5bit �������Ϳ� ����
                                                                                     // 2���� �Է��� 0���� MSBȮ��, �����̹Ƿ� in2�� 2�� ������ ���� �� ���� ���� 
                                if(in1[3] == 1'b1)           // ���� - ���
                                begin
                                    if(REG_ADD_SUB[4] ^ REG_ADD_SUB[3])     // ���� ����� MSB�� ���� 1bit�� ��ȣ�� �ٸ� -> underflow �߻�
                                    begin
                                        ALU_Result <= ALU_Result;           // �״�� ���� �Ϸ�
                                        flowcheck <= 1'b1;                   // flow detect - underflow
                                        overflow <= 1'b0;
                                        underflow <= 1'b1;                         // underflow detect
                                    end
                                    else                    // underflow �߻� X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0];  // ���� ��� ������ ���� 4bit ��� 
                                    end
                                end
                                else if(in1[3] == 1'b0)        // ��� - ���� 
                                begin
                                    if(REG_ADD_SUB[3] == 1'b1) // 7(1000)�̻��̸�, overflow �߻�
                                    begin
                                        ALU_Result <= 4'b0111;
                                        flowcheck <= 1'b1; // flow detect - overflow
                                        overflow <= 1'b1; // overflow detect
                                        underflow <= 1'b0;
                                    end
                                    else // overflow �߻� X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // ���� ��� ������ ���� 4bit ��� 
                                    end
                                end
                            end
                            else // �� ���� ��ȣ�� ���� ���, underflow �߻� X
                            begin
                                ALU_Result <= in1 + (~in2 + 1'b1); // in2�� �� 2�� ���� ���� ��, ���� ���� -> ���� ��� ALU_Result�� ����
                            end
                         end
                    // shift right logical �� ���� - MSB�� ä���� �� in1�� MSB�� �����(��ȣ Ȯ��)`
                    SRL : begin 
                             ALU_Result <= in1 >> in2;
                          end  
                    // shift left logical �� ����     
                    SLL : begin                         
                             ALU_Result <= in1 << in2;      // in2 value��ŭ in1 data shift left
                          end
                    endcase
                end
            end              
endmodule



`timescale 1ns / 1ps

module ALU(
    input clk, rst,                 // clock, reset 
    input [3:0] ALU_Op,             // ALU 연산 동작 control
    input [3:0] Rd1toALU, Rd2toALU, // register 단계에서 주소에 들어있는 값을 반환하여 저장한 변수 
    input [2:0] pst,              // present state
    output reg [3:0] ALU_Result,    // ALU 연산 result
    output reg flowcheck,            // underflow or overflow 나타내는 변수 
    output reg overflow,                  // overflow detect
    output reg underflow                   // underflow detect
    );
    
    wire [3:0] in1, in2;    // ALU의 inputs 
    reg [4:0] REG_ADD_SUB;  // add, substract 결과 5bit가 될 수 있음을 고려하여 임시로 연산 결과를 저장

    // 4bit opcode parameter 구현 
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
              
        
    assign in1 = (pst >= 3'b100) ? Rd1toALU : 3'B000; // present state가 3 이상이면, Rd1toALU 값 in1에 저장, 아니면 0
    assign in2 = (pst >= 3'b100) ? Rd2toALU : 3'B000; // present state 3 이상이면, Rd2toALU 값 in2에 저장, 아니면 0
    
        initial begin   // 초기값
            ALU_Result <= 4'b0000;
            flowcheck <= 1'b0;
        end   
              
    always @ (posedge clk) // posedge trigger 구현
    begin
        if(rst) // reset = 1
        begin
            ALU_Result <= 4'b0000;      // ALU_Result, REG_ADD_SUB, overflow = 0으로 초기화
            REG_ADD_SUB <= 5'b00000; 
            overflow <= 1'b0; 
        end
        else    // reset = 0
        begin
            flowcheck <= 1'b0; // over or underflow detect -> 초기화
            overflow <= 1'b0;       // overflow detect -> 초기화 
            underflow <= 1'b0;       // underflow detect -> 초기화 
            case(ALU_Op)      // ALU Opcode에 따른 연산  
                    NOP : begin
                             ALU_Result <= ALU_Result; // none opcode
                          end
                    Write : begin
                              ALU_Result <= in2;       // Rd2에 있는 data를 write하고 출력
                            end
                    Read : begin
                              ALU_Result <= in1;       // Rd1에 있는 data를 read하고 출력
                           end
                    Copy : begin
                              ALU_Result <= in1;       // Rd1에 있는 data를 copy하고  출력
                           end
                    NOT : begin
                              ALU_Result <= ~in1;      // Rd1에 있는 data를 NOT 연산을 거친 후 출력
                          end
                    AND : begin
                             ALU_Result <= in1 & in2;  // Rd1과 Rd2에 있는 data를 AND 연산을 거친 후 출력
                          end
                    OR : begin
                            ALU_Result <= in1 | in2;   // Rd1과 Rd2에 있는 data를 OR 연산을 거친 후 출력
                          end
                    XOR : begin
                             ALU_Result <= in1 ^ in2;   // Rd1과 Rd2에 있는 data를 XOR 연산을 거친 후 출력
                          end
                    NAND : begin
                              ALU_Result <= ~(in1 & in2);   // Rd1과 Rd2에 있는 data를 NAND 연산을 거친 후 출력
                           end
                    NOR : begin
                            ALU_Result <= ~(in1 | in2);      // Rd1과 Rd2에 있는 data를 NOR 연산을 거친 후 출력
                         end
                    ADD : begin                             // ADD 연산 논리 구현(부호 고려)
                            if(in1[3] ^ in2[3])             // 부호가 다른 경우
                            begin
                                ALU_Result <= in1 + in2;    // overflow detect x, add
                            end
                            else                            // 부호가 같은 경우
                            begin
                                REG_ADD_SUB <= in1 + in2;   // overflow detect를 먼저 하기 위해 덧셈 연산을 한 값 임의의 5bit 레지스터에 저장
                                if(in1[3] == 1'b1)          // 음수 + 음수일 경우
                                begin
                                    if(REG_ADD_SUB[4] == 1'b1)      // -8 이하면(MSB = 1) underflow detect 
                                    begin
                                        ALU_Result <= ALU_Result;   // 그대로 연산 완료
                                        flowcheck <= 1'b1;           // flow detect - underflow
                                        overflow <= 1'b0;
                                        underflow <= 1'b1;                 // underflow detect
                                    end
                                    else                            // undeflow 발생 X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // 연산 결과 값에서 하위 4bit 출력 
                                    end
                               end
                               else if(in1[3] == 1'b0)              // 양수 + 양수
                               begin
                                    if(REG_ADD_SUB[3] == 1'b1)      // 7(1000)이상이면, overflow 발생
                                    begin
                                        ALU_Result <= ALU_Result;   // 그대로 연산 완료
                                        flowcheck <= 1'b1;           // flow detect - overflow
                                        overflow <= 1'b1;                 // overflow detect
                                        underflow <= 1'b0;
                                    end
                                    else                            // overflow 발생 X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // 연산 결과 값에서 하위 4bit 출력 
                                    end
                                end
                             end 
                          end
                          
                    // ADDI 연산 동작 ADD와 동일
                    ADDI : begin                            // ADDI 연산 논리 구현(부호 고려)
                            if(in1[3] ^ in2[3])             // // 부호가 다른 경우
                            begin
                                ALU_Result <= in1 + in2;    // overflow detect x, add
                            end
                            else                            // 부호가 같은 경우
                            begin
                                REG_ADD_SUB <= in1 + in2;   // overflow detect를 먼저 하기 위해 덧셈 연산을 한 값 임의의 5bit 레지스터에 저장
                                if(in1[3] == 1'b1)          // 음수 + 음수
                                begin
                                    if(REG_ADD_SUB[4] == 1'b1)      // -8 이하면(MSB = 1) underflow detect 
                                    begin
                                        ALU_Result <= ALU_Result;   // 그대로 연산 완료
                                        flowcheck <= 1'b1;           // flow detect - underflow
                                        overflow <= 1'b0;
                                        underflow <= 1'b1;                 // underflow detect 
                                    end
                                    else                            // undeflow 발생 X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // 연산 결과 값에서 하위 4bit 출력 
                                    end
                               end
                               else if(in1[3] == 1'b0)              // 양수 + 양수
                               begin
                                    if(REG_ADD_SUB[3] == 1'b1)      // 7(1000)이상이면, overflow 발생
                                    begin
                                        ALU_Result <= ALU_Result;   // 그대로 연산 완료
                                        flowcheck <= 1'b1;           // flow detect - overflow
                                        overflow <= 1'b1;                 // overflow detect
                                        underflow <= 1'b0;
                                    end
                                    else                            // overflow 발생 X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // 연산 결과 값에서 하위 4bit 출력 
                                    end
                                end
                             end 
                          end
                    SUB : begin                             // SUB 연산 논리 구현(부호 고려)
                            if(in1[3] ^ in2[3])             // 부호가 다른 경우                        
                            begin
                                REG_ADD_SUB <= {1'b0, in1} + {1'b0, (~in2 + 1'b1)};  // overflow detect를 먼저 하기 위해 덧셈 연산을 한 값 임의의 5bit 레지스터에 저장
                                                                                     // 2개의 입력은 0으로 MSB확장, 뺄셈이므로 in2는 2의 보수를 취한 후 덧셈 연산 
                                if(in1[3] == 1'b1)           // 음수 - 양수
                                begin
                                    if(REG_ADD_SUB[4] ^ REG_ADD_SUB[3])     // 연산 결과의 MSB와 하위 1bit의 부호가 다름 -> underflow 발생
                                    begin
                                        ALU_Result <= ALU_Result;           // 그대로 연산 완료
                                        flowcheck <= 1'b1;                   // flow detect - underflow
                                        overflow <= 1'b0;
                                        underflow <= 1'b1;                         // underflow detect
                                    end
                                    else                    // underflow 발생 X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // 연산 결과 값에서 하위 4bit 출력 
                                    end
                                end
                                else if(in1[3] == 1'b0)        // 양수 - 음수 
                                begin
                                    if(REG_ADD_SUB[3] == 1'b1) // 7(1000)이상이면, overflow 발생
                                    begin
                                        ALU_Result <= 4'b0111;
                                        flowcheck <= 1'b1; // flow detect - overflow
                                        overflow <= 1'b1; // overflow detect
                                        underflow <= 1'b0;
                                    end
                                    else // overflow 발생 X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // 연산 결과 값에서 하위 4bit 출력 
                                    end
                                end
                            end
                            else            // 두 개의 부호가 같은 경우, underflow 발생 X
                            begin
                                ALU_Result <= in1 + (~in2 + 1'b1);  // in2의 값 2의 보수 취한 뒤, 덧셈 수행 -> 연산 결과 ALU_Result에 넣음
                            end
                         end
                     // SUBI 연산 동작 SUB와 동일 
                    SUBI : begin                            // SUB 연산 논리 구현(부호 고려)
                            if(in1[3] ^ in2[3])             // 부호가 다른 경우                             
                            begin
                                REG_ADD_SUB <= {1'b0, in1} + {1'b0, (~in2 + 1'b1)};  // overflow detect를 먼저 하기 위해 덧셈 연산을 한 값 임의의 5bit 레지스터에 저장
                                                                                     // 2개의 입력은 0으로 MSB확장, 뺄셈이므로 in2는 2의 보수를 취한 후 덧셈 연산 
                                if(in1[3] == 1'b1)           // 음수 - 양수
                                begin
                                    if(REG_ADD_SUB[4] ^ REG_ADD_SUB[3])     // 연산 결과의 MSB와 하위 1bit의 부호가 다름 -> underflow 발생
                                    begin
                                        ALU_Result <= ALU_Result;           // 그대로 연산 완료
                                        flowcheck <= 1'b1;                   // flow detect - underflow
                                        overflow <= 1'b0;
                                        underflow <= 1'b1;                         // underflow detect
                                    end
                                    else                    // underflow 발생 X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0];  // 연산 결과 값에서 하위 4bit 출력 
                                    end
                                end
                                else if(in1[3] == 1'b0)        // 양수 - 음수 
                                begin
                                    if(REG_ADD_SUB[3] == 1'b1) // 7(1000)이상이면, overflow 발생
                                    begin
                                        ALU_Result <= 4'b0111;
                                        flowcheck <= 1'b1; // flow detect - overflow
                                        overflow <= 1'b1; // overflow detect
                                        underflow <= 1'b0;
                                    end
                                    else // overflow 발생 X
                                    begin
                                        ALU_Result <= REG_ADD_SUB[3:0]; // 연산 결과 값에서 하위 4bit 출력 
                                    end
                                end
                            end
                            else // 두 개의 부호가 같은 경우, underflow 발생 X
                            begin
                                ALU_Result <= in1 + (~in2 + 1'b1); // in2의 값 2의 보수 취한 뒤, 덧셈 수행 -> 연산 결과 ALU_Result에 넣음
                            end
                         end
                    // shift right logical 논리 구현 - MSB가 채워질 때 in1의 MSB가 복사됨(부호 확장)`
                    SRL : begin 
                             ALU_Result <= in1 >> in2;
                          end  
                    // shift left logical 논리 구현     
                    SLL : begin                         
                             ALU_Result <= in1 << in2;      // in2 value만큼 in1 data shift left
                          end
                    endcase
                end
            end              
endmodule



`timescale 1ns / 1ps

module REG( // 레지스터 모듈
    input clk,                      // clock 신호 입력
    input Reg_Write,                // control 모듈에서 전달받은 write 신호
    input [3:0] ALU_Result,         // ALU에서 계산된 결과 값
    input [3:0] Rd1, Rd2, Wr,       // 레지스터 주소 입력 (Rd1, Rd2: read 주소, Wr: write 주소)
    input [2:0] pst,                // 현재 상태를 나타내는 입력 신호
    input overflow,                 // ALU에서 발생한 overflow 신호
    output reg [3:0] Rd1toALU,      // ALU로 전달할 첫 번째 레지스터 값 
    output reg [3:0] Rd2toALU       // ALU로 전달할 두 번째 레지스터 값
    );
    
    // 상태 파라미터 정의
    parameter S0 = 3'b000,  // S0: 초기 대기 상태
              S2 = 3'b010,  // S2: Rd1 주소값 처리 상태
              S3 = 3'b011,  // S3: Rd2 주소값 처리 상태
              S4 = 3'b100,  // S4: Wr 주소값 처리 상태
              S5 = 3'b101;  // S5: write 연산 상태
    
    reg [3:0] REG [15:0];   // 4비트  레지스터 파일 (총 16개)
    reg [3:0] Dst_addr;     // 연산 결과를 저장할 destin 레지스터 주소
    
    // 초기 레지스터 값 설정(각각의 레지스터 주소값에 그 주소에 해당하는 값을 데이터 값으로 설정)
    initial begin 
        REG[0] = 4'd0;         REG[5] = 4'd5;             REG[10] = 4'd10;
        REG[1] = 4'd1;         REG[6] = 4'd6;             REG[11] = 4'd11;
        REG[2] = 4'd2;         REG[7] = 4'd7;             REG[12] = 4'd12;
        REG[3] = 4'd3;         REG[8] = 4'd8;             REG[13] = 4'd13;
        REG[4] = 4'd4;         REG[9] = 4'd9;             REG[14] = 4'd14;
                                                          REG[15] = 4'd15; 
        
        Rd1toALU = 0;  // ALU로 전달할 Rd1 초기화
        Rd2toALU = 0;  // ALU로 전달할 Rd2 초기화
    end
    
    // 상태에 따른 레지스터 동작 정의
    always @ (posedge clk)
    begin
        if (pst == S0) begin // S0 상태: 초기화 상태
            Rd1toALU <= 4'b0000; 
            Rd2toALU <= 4'b0000; // ALU 입력값을 모두 0으로 초기화
        end
        
        if (pst == S2) begin // S2 상태: Rd1 주소에 있는 값 읽기
            Rd1toALU <= REG[Rd1]; // Rd1 레지스터 값을 ALU로 전달
        end
        
        if (pst == S3) begin // S3 상태: Rd2 주소에 있는 값 읽기
            Rd2toALU <= REG[Rd2]; // Rd2 레지스터 값을 ALU로 전달
        end
        
        if (pst == S4) begin // S4 상태: Wr 주소 설정
            Dst_addr <= Wr; // 목적지 레지스터 주소를 저장
        end
        
        if (pst == S5) begin // S5 상태: 쓰기 연산 수행
            if (Reg_Write == 1'b1) begin // 쓰기 신호가 활성화된 경우
                if (Dst_addr == 4'b0000) begin // 대상 레지스터가 $0인 경우
                    REG[Dst_addr] <= 4'b0000; // 레지스터 $0은 항상 0으로 유지
                end
                else begin // 대상 레지스터가 $0이 아닌 경우
                    if (overflow) begin // 오버플로우가 발생한 경우
                        REG[Dst_addr] <= REG[Dst_addr]; // 기존 값을 유지
                    end
                    else begin 
                        REG[Dst_addr] <= ALU_Result; // 연산 결과를 목적지 레지스터에 저장
                    end
                end
            end
        end
    end   
endmodule

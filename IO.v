`timescale 1ns / 1ps

module IO( 
    // 입력 신호
    input clk,                   // 클럭 신호
    input flowcheck,             // 오버플로/언더플로 감지 여부
    input overflow,              // 오버플로 감지 신호
    input underflow,             // 언더플로 감지 신호
    input [3:0] sw, btn, alu_result, // 4비트 스위치, 버튼 입력 및 ALU 결과

    // 출력 신호
    output reg [3:0] op, Rd1, Rd2, wr, // 명령어 및 데이터 레지스터 값
    output reg [3:0] ssd1, ssd2, ssd3, ssd4, // 7세그먼트 디스플레이 출력
    output reg [3:0] led,         // LED 상태
    output reg [2:0] pst          // 상태를 나타내는 3비트 출력
);

    // 리셋 버튼 정의
    wire rst = btn[3]; // btn[3]: IDLE 상태로 리셋

    // 초기값 설정
    initial begin
        op = 0; Rd1 = 0; Rd2 = 0; wr = 0; // 데이터 초기화
        ssd1 = 0; ssd2 = 0; ssd3 = 0; ssd4 = 0; // SSD 초기화
        led = 0; pst = 0; // LED 및 상태 초기화
    end

    // 상태 변화 로직
    always @(posedge clk) begin
        case (pst)
            0: // IDLE 상태
            begin
                led <= 4'b0000; // 모든 LED 꺼짐
                {ssd4, ssd3, ssd2, ssd1} <= 0; // SSD 디스플레이 초기화
                {op, Rd1, Rd2, wr} <= 0; // 데이터 초기화
                if (btn[0]) pst <= 1; // btn[0]으로 다음 상태로 전환
                else if (rst) pst <= 0; // 리셋 버튼으로 IDLE 유지
            end

            1: // 명령어 입력 1
            begin
                {led, ssd4, op} <= {4'b1000, sw, sw}; // LED, SSD4, op 업데이트
                if (btn[0]) pst <= 2; // btn[0]으로 다음 상태로 전환
                else if (rst) pst <= 0; // 리셋 버튼으로 IDLE로 복귀
            end

            2: // 명령어 입력 2
            begin
                {led, ssd3, Rd1} <= {4'b0100, sw, sw}; // LED, SSD3, Rd1 업데이트
                if (btn[0]) pst <= 3; // btn[0]으로 다음 상태로 전환
                else if (rst) pst <= 0; // 리셋 버튼으로 IDLE로 복귀
            end

            3: // 명령어 입력 3
            begin
                {led, ssd2, Rd2} <= {4'b0010, sw, sw}; // LED, SSD2, Rd2 업데이트
                if (btn[0]) pst <= 4; // btn[0]으로 다음 상태로 전환
                else if (rst) pst <= 0; // 리셋 버튼으로 IDLE로 복귀
            end

            4: // 명령어 입력 4
            begin
                {led, ssd1, wr} <= {4'b0001, sw, sw}; // LED, SSD1, wr 업데이트
                if (btn[0]) pst <= 5; // btn[0]으로 다음 상태로 전환
                else if (rst) pst <= 0; // 리셋 버튼으로 IDLE로 복귀
            end

            5: // 실행 상태
            begin
                if (flowcheck) begin // 오버플로 또는 언더플로 발생 시
                    if (overflow) led <= 4'b1100; // 오버플로: LED = 1100
                    if (underflow) led <= 4'b0011; // 언더플로: LED = 0011
                end else begin
                    led <= 4'b1001; // 정상 작동: LED = 1001
                end
                if (btn[0]) pst <= 6; // btn[0]으로 다음 상태로 전환
                else if (rst) pst <= 0; // 리셋 버튼으로 IDLE로 복귀
            end

            6: // 완료 상태
            begin
                led <= 4'b1111; // 모든 LED 켜짐
                if (btn == 4'b0001 || btn == 4'b1000) pst <= 0; // IDLE로 복귀
                else if (btn == 4'b0010) begin // btn[1]으로 SSD에 데이터 출력
                    {ssd4, ssd3, ssd2, ssd1} <= {op, Rd1, Rd2, wr};
                end else if (flowcheck) begin
                    if (overflow) {ssd4, ssd3, ssd2, ssd1} <= {4{4'b1111}}; // 'FFFF'
                    else if (underflow) {ssd4, ssd3, ssd2, ssd1} <= {4{4'b1010}}; // 'AAAA'
                end else begin
                    // 정상 결과 출력
                    {ssd4, ssd3, ssd2, ssd1} <= {{3'b000, alu_result[3]}, 
                                                 {3'b000, alu_result[2]}, 
                                                 {3'b000, alu_result[1]}, 
                                                 {3'b000, alu_result[0]}};
                end
            end
        endcase
    end
endmodule

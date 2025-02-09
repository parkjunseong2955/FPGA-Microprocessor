`timescale 1ns / 1ps

module SSD(
    input clk_1M,               // 1MHz 클럭 입력
    input [3:0] Opcode,         // Opcode 데이터 입력 (4비트)
    input [3:0] Rd1,            // Rd1 데이터 입력 (4비트)
    input [3:0] Rd2,            // Rd2 데이터 입력 (4비트)
    input [3:0] Wr,             // Wr 데이터 입력 (4비트)
    output [1:0] seg_en,        // 7세그먼트 디스플레이 활성화 신호
    output [6:0] seg_ab,        // 7세그먼트 디스플레이 A, B 출력
    output [6:0] seg_cd         // 7세그먼트 디스플레이 C, D 출력
    );

    // 내부 신호 정의
    wire [3:0] hex_12;          // seg_ab에 표시할 데이터
    wire [3:0] hex_34;          // seg_cd에 표시할 데이터

    // seg_en 제어: 클럭 신호에 따라 7세그먼트 활성화
    assign seg_en = clk_1M ? 2'b11 : 2'b00; 
    // 클럭 신호가 반전될 때마다 seg_en 값을 토글하여 두 세그먼트를 번갈아 활성화

    // seg_ab에 표시할 데이터 선택
    assign hex_12 = clk_1M ? Opcode : Rd1; 
    // 클럭 신호에 따라 Opcode와 Rd1 데이터를 번갈아 표시

    // seg_cd에 표시할 데이터 선택
    assign hex_34 = clk_1M ? Rd2 : Wr; 
    // 클럭 신호에 따라 Rd2와 Wr 데이터를 번갈아 표시

    // HEX2SSD 모듈을 이용한 데이터 변환
    HEX2SSD h0 (.hex(hex_12), .seg(seg_ab)); // hex_12 데이터를 seg_ab로 변환
    HEX2SSD h1 (.hex(hex_34), .seg(seg_cd)); // hex_34 데이터를 seg_cd로 변환

endmodule

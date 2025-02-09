`timescale 1ns / 1ps

module SYNC( // Metastability 방지용 동기화 모듈
    input clk,           // 클럭 신호 (동기화 기준 신호)
    input async_in,      // 비동기 입력 신호
    output reg sync_out  // 동기화된 출력 신호
    );
    
    reg t; // 첫 번째 플립플롭 출력 신호 (임시 저장)

    always @(posedge clk) begin
        t <= async_in;     // 비동기 입력 신호를 첫 번째 플립플롭으로 저장
        sync_out <= t;     // 첫 번째 플립플롭의 출력을 두 번째 플립플롭으로 전달
    end
endmodule

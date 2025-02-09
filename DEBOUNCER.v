`timescale 1ns / 1ps

// DEBOUNCER 모듈: 버튼 등의 신호에서 스위칭 시 발생하는 BOUNCE를 제거
module DEBOUNCER #(parameter N = 30, parameter K = 1000)( 
    // 파라미터:
    // N: 디바운스가 완료되었다고 판단할 카운트 값 (기본값 30)
    // K: 카운터의 비트 수 (기본값 1000)
    input clk,            // 클럭 신호
    input noisy,          // BOUNCE가 포함된 비동기 입력 신호
    output debounced      // 디바운스 처리된 안정적인 출력 신호
    );
    
    reg [K-1:0] cnt;      // K비트 카운터 (입력 신호가 일정 시간 동안 안정적인지 확인)
    
    always @(posedge clk) begin
        if (noisy) 
            cnt <= cnt + 1'b1; // noisy 신호가 유지되는 동안 카운터 증가
        else 
            cnt <= 0; // noisy 신호가 떨어지면 카운터 초기화
    end
    
    // debounced 출력: 카운터 값이 N에 도달하면 안정적인 신호로 간주
    assign debounced = (cnt == N) ? 1'b1 : 1'b0;

endmodule

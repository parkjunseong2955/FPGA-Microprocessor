`timescale 1ns / 1ps

module clk_gen_100M(
    input clk_ref, // 입력 기준 클럭 (125MHz)
    input rst,     // 리셋 신호
    output clk_100M // 출력 클럭 (100MHz)
    );

    wire clk_125M = clk_ref; // 입력 기준 클럭을 clk_125M에 연결

    // 클럭 생성기 인스턴스
    clk_wiz_0 clk_gen ( 
        .clk_out1(clk_100M), // 100MHz 출력 클럭
        .reset(rst),         // 리셋 신호 입력
        .clk_in1(clk_ref)    // 125MHz 입력 클럭
    );

endmodule

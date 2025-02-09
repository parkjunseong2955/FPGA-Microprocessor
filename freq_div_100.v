`timescale 1ns / 1ps

module freq_div_100(
        input clk_ref,      // 입력 클럭 (기준 클럭)
        input rst,          // 리셋 신호
        output reg clk_div  // 출력 분주된 클럭
    );
    
    reg [5:0] cnt; // 6비트 카운터, 0~49까지 카운트 가능

    always @(posedge clk_ref or posedge rst) begin
        if (rst) begin
            // 리셋 신호가 활성화되면 카운터와 출력 클럭 초기화
            cnt <= 6'd0;
            clk_div <= 1'd0;
        end else begin
            if (cnt == 6'd49) begin
                // 카운터가 49에 도달하면 카운터를 초기화하고 출력 클럭 반전
                cnt <= 6'd0;
                clk_div <= ~clk_div; // 50개 클럭 주기마다 출력 클럭 반전
            end else begin
                // 카운터 증가
                cnt <= cnt + 1'b1;
            end
        end
    end
endmodule

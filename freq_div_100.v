`timescale 1ns / 1ps

module freq_div_100(
        input clk_ref,      // �Է� Ŭ�� (���� Ŭ��)
        input rst,          // ���� ��ȣ
        output reg clk_div  // ��� ���ֵ� Ŭ��
    );
    
    reg [5:0] cnt; // 6��Ʈ ī����, 0~49���� ī��Ʈ ����

    always @(posedge clk_ref or posedge rst) begin
        if (rst) begin
            // ���� ��ȣ�� Ȱ��ȭ�Ǹ� ī���Ϳ� ��� Ŭ�� �ʱ�ȭ
            cnt <= 6'd0;
            clk_div <= 1'd0;
        end else begin
            if (cnt == 6'd49) begin
                // ī���Ͱ� 49�� �����ϸ� ī���͸� �ʱ�ȭ�ϰ� ��� Ŭ�� ����
                cnt <= 6'd0;
                clk_div <= ~clk_div; // 50�� Ŭ�� �ֱ⸶�� ��� Ŭ�� ����
            end else begin
                // ī���� ����
                cnt <= cnt + 1'b1;
            end
        end
    end
endmodule

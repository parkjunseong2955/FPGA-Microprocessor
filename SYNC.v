`timescale 1ns / 1ps

module SYNC( // Metastability ������ ����ȭ ���
    input clk,           // Ŭ�� ��ȣ (����ȭ ���� ��ȣ)
    input async_in,      // �񵿱� �Է� ��ȣ
    output reg sync_out  // ����ȭ�� ��� ��ȣ
    );
    
    reg t; // ù ��° �ø��÷� ��� ��ȣ (�ӽ� ����)

    always @(posedge clk) begin
        t <= async_in;     // �񵿱� �Է� ��ȣ�� ù ��° �ø��÷����� ����
        sync_out <= t;     // ù ��° �ø��÷��� ����� �� ��° �ø��÷����� ����
    end
endmodule

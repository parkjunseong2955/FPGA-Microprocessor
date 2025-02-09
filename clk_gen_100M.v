`timescale 1ns / 1ps

module clk_gen_100M(
    input clk_ref, // �Է� ���� Ŭ�� (125MHz)
    input rst,     // ���� ��ȣ
    output clk_100M // ��� Ŭ�� (100MHz)
    );

    wire clk_125M = clk_ref; // �Է� ���� Ŭ���� clk_125M�� ����

    // Ŭ�� ������ �ν��Ͻ�
    clk_wiz_0 clk_gen ( 
        .clk_out1(clk_100M), // 100MHz ��� Ŭ��
        .reset(rst),         // ���� ��ȣ �Է�
        .clk_in1(clk_ref)    // 125MHz �Է� Ŭ��
    );

endmodule

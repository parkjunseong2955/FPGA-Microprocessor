`timescale 1ns / 1ps

module SSD(
    input clk_1M,               // 1MHz Ŭ�� �Է�
    input [3:0] Opcode,         // Opcode ������ �Է� (4��Ʈ)
    input [3:0] Rd1,            // Rd1 ������ �Է� (4��Ʈ)
    input [3:0] Rd2,            // Rd2 ������ �Է� (4��Ʈ)
    input [3:0] Wr,             // Wr ������ �Է� (4��Ʈ)
    output [1:0] seg_en,        // 7���׸�Ʈ ���÷��� Ȱ��ȭ ��ȣ
    output [6:0] seg_ab,        // 7���׸�Ʈ ���÷��� A, B ���
    output [6:0] seg_cd         // 7���׸�Ʈ ���÷��� C, D ���
    );

    // ���� ��ȣ ����
    wire [3:0] hex_12;          // seg_ab�� ǥ���� ������
    wire [3:0] hex_34;          // seg_cd�� ǥ���� ������

    // seg_en ����: Ŭ�� ��ȣ�� ���� 7���׸�Ʈ Ȱ��ȭ
    assign seg_en = clk_1M ? 2'b11 : 2'b00; 
    // Ŭ�� ��ȣ�� ������ ������ seg_en ���� ����Ͽ� �� ���׸�Ʈ�� ������ Ȱ��ȭ

    // seg_ab�� ǥ���� ������ ����
    assign hex_12 = clk_1M ? Opcode : Rd1; 
    // Ŭ�� ��ȣ�� ���� Opcode�� Rd1 �����͸� ������ ǥ��

    // seg_cd�� ǥ���� ������ ����
    assign hex_34 = clk_1M ? Rd2 : Wr; 
    // Ŭ�� ��ȣ�� ���� Rd2�� Wr �����͸� ������ ǥ��

    // HEX2SSD ����� �̿��� ������ ��ȯ
    HEX2SSD h0 (.hex(hex_12), .seg(seg_ab)); // hex_12 �����͸� seg_ab�� ��ȯ
    HEX2SSD h1 (.hex(hex_34), .seg(seg_cd)); // hex_34 �����͸� seg_cd�� ��ȯ

endmodule

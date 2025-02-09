`timescale 1ns / 1ps

module REG( // �������� ���
    input clk,                      // clock ��ȣ �Է�
    input Reg_Write,                // control ��⿡�� ���޹��� write ��ȣ
    input [3:0] ALU_Result,         // ALU���� ���� ��� ��
    input [3:0] Rd1, Rd2, Wr,       // �������� �ּ� �Է� (Rd1, Rd2: read �ּ�, Wr: write �ּ�)
    input [2:0] pst,                // ���� ���¸� ��Ÿ���� �Է� ��ȣ
    input overflow,                 // ALU���� �߻��� overflow ��ȣ
    output reg [3:0] Rd1toALU,      // ALU�� ������ ù ��° �������� �� 
    output reg [3:0] Rd2toALU       // ALU�� ������ �� ��° �������� ��
    );
    
    // ���� �Ķ���� ����
    parameter S0 = 3'b000,  // S0: �ʱ� ��� ����
              S2 = 3'b010,  // S2: Rd1 �ּҰ� ó�� ����
              S3 = 3'b011,  // S3: Rd2 �ּҰ� ó�� ����
              S4 = 3'b100,  // S4: Wr �ּҰ� ó�� ����
              S5 = 3'b101;  // S5: write ���� ����
    
    reg [3:0] REG [15:0];   // 4��Ʈ  �������� ���� (�� 16��)
    reg [3:0] Dst_addr;     // ���� ����� ������ destin �������� �ּ�
    
    // �ʱ� �������� �� ����(������ �������� �ּҰ��� �� �ּҿ� �ش��ϴ� ���� ������ ������ ����)
    initial begin 
        REG[0] = 4'd0;         REG[5] = 4'd5;             REG[10] = 4'd10;
        REG[1] = 4'd1;         REG[6] = 4'd6;             REG[11] = 4'd11;
        REG[2] = 4'd2;         REG[7] = 4'd7;             REG[12] = 4'd12;
        REG[3] = 4'd3;         REG[8] = 4'd8;             REG[13] = 4'd13;
        REG[4] = 4'd4;         REG[9] = 4'd9;             REG[14] = 4'd14;
                                                          REG[15] = 4'd15; 
        
        Rd1toALU = 0;  // ALU�� ������ Rd1 �ʱ�ȭ
        Rd2toALU = 0;  // ALU�� ������ Rd2 �ʱ�ȭ
    end
    
    // ���¿� ���� �������� ���� ����
    always @ (posedge clk)
    begin
        if (pst == S0) begin // S0 ����: �ʱ�ȭ ����
            Rd1toALU <= 4'b0000; 
            Rd2toALU <= 4'b0000; // ALU �Է°��� ��� 0���� �ʱ�ȭ
        end
        
        if (pst == S2) begin // S2 ����: Rd1 �ּҿ� �ִ� �� �б�
            Rd1toALU <= REG[Rd1]; // Rd1 �������� ���� ALU�� ����
        end
        
        if (pst == S3) begin // S3 ����: Rd2 �ּҿ� �ִ� �� �б�
            Rd2toALU <= REG[Rd2]; // Rd2 �������� ���� ALU�� ����
        end
        
        if (pst == S4) begin // S4 ����: Wr �ּ� ����
            Dst_addr <= Wr; // ������ �������� �ּҸ� ����
        end
        
        if (pst == S5) begin // S5 ����: ���� ���� ����
            if (Reg_Write == 1'b1) begin // ���� ��ȣ�� Ȱ��ȭ�� ���
                if (Dst_addr == 4'b0000) begin // ��� �������Ͱ� $0�� ���
                    REG[Dst_addr] <= 4'b0000; // �������� $0�� �׻� 0���� ����
                end
                else begin // ��� �������Ͱ� $0�� �ƴ� ���
                    if (overflow) begin // �����÷ο찡 �߻��� ���
                        REG[Dst_addr] <= REG[Dst_addr]; // ���� ���� ����
                    end
                    else begin 
                        REG[Dst_addr] <= ALU_Result; // ���� ����� ������ �������Ϳ� ����
                    end
                end
            end
        end
    end   
endmodule

`timescale 1ns / 1ps

// DEBOUNCER ���: ��ư ���� ��ȣ���� ����Ī �� �߻��ϴ� BOUNCE�� ����
module DEBOUNCER #(parameter N = 30, parameter K = 1000)( 
    // �Ķ����:
    // N: ��ٿ�� �Ϸ�Ǿ��ٰ� �Ǵ��� ī��Ʈ �� (�⺻�� 30)
    // K: ī������ ��Ʈ �� (�⺻�� 1000)
    input clk,            // Ŭ�� ��ȣ
    input noisy,          // BOUNCE�� ���Ե� �񵿱� �Է� ��ȣ
    output debounced      // ��ٿ ó���� �������� ��� ��ȣ
    );
    
    reg [K-1:0] cnt;      // K��Ʈ ī���� (�Է� ��ȣ�� ���� �ð� ���� ���������� Ȯ��)
    
    always @(posedge clk) begin
        if (noisy) 
            cnt <= cnt + 1'b1; // noisy ��ȣ�� �����Ǵ� ���� ī���� ����
        else 
            cnt <= 0; // noisy ��ȣ�� �������� ī���� �ʱ�ȭ
    end
    
    // debounced ���: ī���� ���� N�� �����ϸ� �������� ��ȣ�� ����
    assign debounced = (cnt == N) ? 1'b1 : 1'b0;

endmodule

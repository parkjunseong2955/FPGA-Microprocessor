`timescale 1ns / 1ps

module IO( 
    // �Է� ��ȣ
    input clk,                   // Ŭ�� ��ȣ
    input flowcheck,             // �����÷�/����÷� ���� ����
    input overflow,              // �����÷� ���� ��ȣ
    input underflow,             // ����÷� ���� ��ȣ
    input [3:0] sw, btn, alu_result, // 4��Ʈ ����ġ, ��ư �Է� �� ALU ���

    // ��� ��ȣ
    output reg [3:0] op, Rd1, Rd2, wr, // ��ɾ� �� ������ �������� ��
    output reg [3:0] ssd1, ssd2, ssd3, ssd4, // 7���׸�Ʈ ���÷��� ���
    output reg [3:0] led,         // LED ����
    output reg [2:0] pst          // ���¸� ��Ÿ���� 3��Ʈ ���
);

    // ���� ��ư ����
    wire rst = btn[3]; // btn[3]: IDLE ���·� ����

    // �ʱⰪ ����
    initial begin
        op = 0; Rd1 = 0; Rd2 = 0; wr = 0; // ������ �ʱ�ȭ
        ssd1 = 0; ssd2 = 0; ssd3 = 0; ssd4 = 0; // SSD �ʱ�ȭ
        led = 0; pst = 0; // LED �� ���� �ʱ�ȭ
    end

    // ���� ��ȭ ����
    always @(posedge clk) begin
        case (pst)
            0: // IDLE ����
            begin
                led <= 4'b0000; // ��� LED ����
                {ssd4, ssd3, ssd2, ssd1} <= 0; // SSD ���÷��� �ʱ�ȭ
                {op, Rd1, Rd2, wr} <= 0; // ������ �ʱ�ȭ
                if (btn[0]) pst <= 1; // btn[0]���� ���� ���·� ��ȯ
                else if (rst) pst <= 0; // ���� ��ư���� IDLE ����
            end

            1: // ��ɾ� �Է� 1
            begin
                {led, ssd4, op} <= {4'b1000, sw, sw}; // LED, SSD4, op ������Ʈ
                if (btn[0]) pst <= 2; // btn[0]���� ���� ���·� ��ȯ
                else if (rst) pst <= 0; // ���� ��ư���� IDLE�� ����
            end

            2: // ��ɾ� �Է� 2
            begin
                {led, ssd3, Rd1} <= {4'b0100, sw, sw}; // LED, SSD3, Rd1 ������Ʈ
                if (btn[0]) pst <= 3; // btn[0]���� ���� ���·� ��ȯ
                else if (rst) pst <= 0; // ���� ��ư���� IDLE�� ����
            end

            3: // ��ɾ� �Է� 3
            begin
                {led, ssd2, Rd2} <= {4'b0010, sw, sw}; // LED, SSD2, Rd2 ������Ʈ
                if (btn[0]) pst <= 4; // btn[0]���� ���� ���·� ��ȯ
                else if (rst) pst <= 0; // ���� ��ư���� IDLE�� ����
            end

            4: // ��ɾ� �Է� 4
            begin
                {led, ssd1, wr} <= {4'b0001, sw, sw}; // LED, SSD1, wr ������Ʈ
                if (btn[0]) pst <= 5; // btn[0]���� ���� ���·� ��ȯ
                else if (rst) pst <= 0; // ���� ��ư���� IDLE�� ����
            end

            5: // ���� ����
            begin
                if (flowcheck) begin // �����÷� �Ǵ� ����÷� �߻� ��
                    if (overflow) led <= 4'b1100; // �����÷�: LED = 1100
                    if (underflow) led <= 4'b0011; // ����÷�: LED = 0011
                end else begin
                    led <= 4'b1001; // ���� �۵�: LED = 1001
                end
                if (btn[0]) pst <= 6; // btn[0]���� ���� ���·� ��ȯ
                else if (rst) pst <= 0; // ���� ��ư���� IDLE�� ����
            end

            6: // �Ϸ� ����
            begin
                led <= 4'b1111; // ��� LED ����
                if (btn == 4'b0001 || btn == 4'b1000) pst <= 0; // IDLE�� ����
                else if (btn == 4'b0010) begin // btn[1]���� SSD�� ������ ���
                    {ssd4, ssd3, ssd2, ssd1} <= {op, Rd1, Rd2, wr};
                end else if (flowcheck) begin
                    if (overflow) {ssd4, ssd3, ssd2, ssd1} <= {4{4'b1111}}; // 'FFFF'
                    else if (underflow) {ssd4, ssd3, ssd2, ssd1} <= {4{4'b1010}}; // 'AAAA'
                end else begin
                    // ���� ��� ���
                    {ssd4, ssd3, ssd2, ssd1} <= {{3'b000, alu_result[3]}, 
                                                 {3'b000, alu_result[2]}, 
                                                 {3'b000, alu_result[1]}, 
                                                 {3'b000, alu_result[0]}};
                end
            end
        endcase
    end
endmodule

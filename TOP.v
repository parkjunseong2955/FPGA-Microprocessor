`timescale 1ns / 1ps

module TOP(
    input clk_ref, // �ܺ� Ŭ�� �Է� (���� Ŭ��)
    input [3:0] sw, // 4��Ʈ ����ġ �Է� (��ɾ� ������ ���)
    // ��ư ����:
    // btn[0]: ���� ���·� ��ȯ
    // btn[1]: ��� ���
    // btn[3]: IDLE�� ����
    // btn[2]: ������� ����
    input [3:0] btn,
    output [6:0] seg_ab, seg_cd, // 7���׸�Ʈ ���÷��� ���
    output [1:0] seg_en, // 7���׸�Ʈ ���÷��� ���� ��ȣ
    output [3:0] led // ���� ���¸� ��Ÿ���� LED ���
);

    wire clk_100M, clk_1M; // 100MHz�� 1MHz Ŭ�� ��ȣ
    wire [3:0] Opcode, Rd1, Rd2, Wr; // IO ����� �Է� ��ɾ� �� ������ ��������
    wire [3:0] ssd4, ssd3, ssd2, ssd1; // SSD ��⿡ ������ ������
    wire [2:0] pst; // ���� ���� ���
    wire flowcheck; // ����÷� �Ǵ� �����÷� �߻� ����
    wire overflow; // �����÷� �߻� ����
    wire underflow; // ����÷� �߻� ����
    wire [3:0] ALU_Op; // ���� ��ȣ (ALU ���� �ڵ�)
    wire Reg_Write; // �������� ���� Ȱ��ȭ ��ȣ
    wire [3:0] Rd1toALU, Rd2toALU; // ALU�� �Է� ������
    wire ALU_Src; // ALU �Է� ���� ��ȣ
    wire [3:0] ALU_Result; // ALU ��� ���
    wire [3:0] in1, in2; // ALU�� �Է°�
    wire [3:0] S_btn, D_btn, E_btn; // ����ȭ(SYNC) �� ��ٿ(DEBOUNCER) ó���� ��ư �Է�
    wire [3:0] Rd2_temp; // Rd2 ���� �ӽ� ���� (I ���� ��ɾ�� �����ͷ� ���)

    // Ŭ�� ���� �� ����
    clk_gen_100M g0 (.clk_ref(clk_ref), .rst(btn[3]), .clk_100M(clk_100M)); // 100MHz Ŭ�� ����
    freq_div_100 f0 (.clk_ref(clk_100M), .rst(btn[3]), .clk_div(clk_1M)); // 1MHz�� Ŭ�� ����

    // ALU �Է� ��ȣ ����
    assign in1 = Rd1toALU; // ALU�� ù ��° �Է�
    assign in2 = (pst != 3'b100) ? in2 : ((ALU_Src == 1'b0) ? Rd2toALU : Rd2_temp); 
    // ���°� S3�� �ƴ� ��� ���� �� ����
    // ALU_Src�� 0�̸� Rd2toALU ���, 1�̸� Rd2_temp ���

    // ��ư ��ȣ ����
    assign E_btn = {btn[3:1], D_btn[0]}; // D_btn[0]���� btn[0]�� ������ ���� (���°� �� ���� �ٲ��)

    // Rd2_temp ���� (I ���� ��ɾ�� �����ͷ� ���� �� ����)
    assign Rd2_temp = (pst == 3'b011) ? Rd2 : Rd2_temp; 

    // �ֿ� ��� ����
    CONTROL    C0 (.Opcode(Opcode), .clk(clk_100M), .rst(E_btn[3]), .pst(pst), 
                        .Reg_Write(Reg_Write), .ALU_Src(ALU_Src), .ALU_Op(ALU_Op));
    IO         I0 (.clk(clk_100M), .sw(sw), .btn(E_btn), .alu_result(ALU_Result), 
                        .flowcheck(flowcheck), .overflow(overflow), .underflow(underflow), 
                        .led(led), .op(Opcode), .Rd1(Rd1), .Rd2(Rd2), .wr(Wr), 
                        .ssd4(ssd4), .ssd3(ssd3), .ssd2(ssd2), .ssd1(ssd1), .pst(pst));
    REG        R0 (.clk(clk_100M), .ALU_Result(ALU_Result), .Rd1(Rd1), .Rd2(Rd2), .Wr(Wr), 
                        .pst(pst), .overflow(overflow), .Reg_Write(Reg_Write), 
                        .Rd1toALU(Rd1toALU), .Rd2toALU(Rd2toALU));
    ALU        A0 (.clk(clk_100M), .rst(E_btn[3]), .Rd1toALU(in1), .Rd2toALU(in2), 
                        .ALU_Op(ALU_Op), .pst(pst), .ALU_Result(ALU_Result), 
                        .flowcheck(flowcheck), .overflow(overflow), .underflow(underflow));
    SSD        SSD0 (.clk_1M(clk_1M), .Opcode(ssd4), .Rd1(ssd3), .Rd2(ssd2), .Wr(ssd1), 
                        .seg_ab(seg_ab), .seg_cd(seg_cd), .seg_en(seg_en));

    // ��ư ����ȭ �� ��ٿ ó��
    SYNC      S0 (.clk(clk_100M), .async_in(btn[0]), .sync_out(S_btn[0]));    
    DEBOUNCER D0 (.clk(clk_100M), .noisy(S_btn[0]), .debounced(D_btn[0]));
    SYNC      S1 (.clk(clk_100M), .async_in(btn[1]), .sync_out(S_btn[1]));    
    DEBOUNCER D1 (.clk(clk_100M), .noisy(S_btn[1]), .debounced(D_btn[1]));
    SYNC      S2 (.clk(clk_100M), .async_in(btn[2]), .sync_out(S_btn[2]));    
    DEBOUNCER D2 (.clk(clk_100M), .noisy(S_btn[2]), .debounced(D_btn[2]));
    SYNC      S3 (.clk(clk_100M), .async_in(btn[3]), .sync_out(S_btn[3]));    
    DEBOUNCER D3 (.clk(clk_100M), .noisy(S_btn[3]), .debounced(D_btn[3]));

endmodule

`timescale 1ns / 1ps

module TOP(
    input clk_ref, // 외부 클럭 입력 (기준 클럭)
    input [3:0] sw, // 4비트 스위치 입력 (명령어 구성에 사용)
    // 버튼 설명:
    // btn[0]: 다음 상태로 전환
    // btn[1]: 결과 출력
    // btn[3]: IDLE로 리셋
    // btn[2]: 사용하지 않음
    input [3:0] btn,
    output [6:0] seg_ab, seg_cd, // 7세그먼트 디스플레이 출력
    output [1:0] seg_en, // 7세그먼트 디스플레이 제어 신호
    output [3:0] led // 현재 상태를 나타내는 LED 출력
);

    wire clk_100M, clk_1M; // 100MHz와 1MHz 클럭 신호
    wire [3:0] Opcode, Rd1, Rd2, Wr; // IO 모듈의 입력 명령어 및 데이터 레지스터
    wire [3:0] ssd4, ssd3, ssd2, ssd1; // SSD 모듈에 전달할 데이터
    wire [2:0] pst; // 현재 상태 출력
    wire flowcheck; // 언더플로 또는 오버플로 발생 여부
    wire overflow; // 오버플로 발생 여부
    wire underflow; // 언더플로 발생 여부
    wire [3:0] ALU_Op; // 제어 신호 (ALU 연산 코드)
    wire Reg_Write; // 레지스터 쓰기 활성화 신호
    wire [3:0] Rd1toALU, Rd2toALU; // ALU의 입력 데이터
    wire ALU_Src; // ALU 입력 선택 신호
    wire [3:0] ALU_Result; // ALU 계산 결과
    wire [3:0] in1, in2; // ALU의 입력값
    wire [3:0] S_btn, D_btn, E_btn; // 동기화(SYNC) 및 디바운스(DEBOUNCER) 처리된 버튼 입력
    wire [3:0] Rd2_temp; // Rd2 값을 임시 저장 (I 형식 명령어에서 데이터로 사용)

    // 클럭 생성 및 분주
    clk_gen_100M g0 (.clk_ref(clk_ref), .rst(btn[3]), .clk_100M(clk_100M)); // 100MHz 클럭 생성
    freq_div_100 f0 (.clk_ref(clk_100M), .rst(btn[3]), .clk_div(clk_1M)); // 1MHz로 클럭 분주

    // ALU 입력 신호 매핑
    assign in1 = Rd1toALU; // ALU의 첫 번째 입력
    assign in2 = (pst != 3'b100) ? in2 : ((ALU_Src == 1'b0) ? Rd2toALU : Rd2_temp); 
    // 상태가 S3가 아닌 경우 이전 값 유지
    // ALU_Src가 0이면 Rd2toALU 사용, 1이면 Rd2_temp 사용

    // 버튼 신호 매핑
    assign E_btn = {btn[3:1], D_btn[0]}; // D_btn[0]으로 btn[0]의 동작을 제어 (상태가 한 번만 바뀌도록)

    // Rd2_temp 매핑 (I 형식 명령어에서 데이터로 사용될 값 저장)
    assign Rd2_temp = (pst == 3'b011) ? Rd2 : Rd2_temp; 

    // 주요 모듈 연결
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

    // 버튼 동기화 및 디바운스 처리
    SYNC      S0 (.clk(clk_100M), .async_in(btn[0]), .sync_out(S_btn[0]));    
    DEBOUNCER D0 (.clk(clk_100M), .noisy(S_btn[0]), .debounced(D_btn[0]));
    SYNC      S1 (.clk(clk_100M), .async_in(btn[1]), .sync_out(S_btn[1]));    
    DEBOUNCER D1 (.clk(clk_100M), .noisy(S_btn[1]), .debounced(D_btn[1]));
    SYNC      S2 (.clk(clk_100M), .async_in(btn[2]), .sync_out(S_btn[2]));    
    DEBOUNCER D2 (.clk(clk_100M), .noisy(S_btn[2]), .debounced(D_btn[2]));
    SYNC      S3 (.clk(clk_100M), .async_in(btn[3]), .sync_out(S_btn[3]));    
    DEBOUNCER D3 (.clk(clk_100M), .noisy(S_btn[3]), .debounced(D_btn[3]));

endmodule

`timescale 1ns / 1ps

module RAM (
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] addr,
    input  logic [31:0] wData,
    output logic [31:0] rData
);
    logic [31:0] mem[0:2**4-1]; // 0~15 : 0x00 ~ 0x0F => 0x10 * 4 = 0x40
    // 워드 하나당 크기는 4바이트, 총 워드는 16개(메모리 크기 16층) = 전체 메모리 크기 16*4 = 64바이트 (0x40)

    always_ff @(posedge clk) begin
        if (we) mem[addr[31:2]] <= wData;
    end

    assign rData = mem[addr[31:2]];
endmodule

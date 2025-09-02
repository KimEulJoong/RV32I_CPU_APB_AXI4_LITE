`timescale 1ns / 1ps

module RAM (
    input  logic        clk,
    input  logic        we,
    input  logic [ 2:0] funct3,
    input  logic [31:0] addr,
    input  logic [31:0] wData,
    output logic [31:0] rData
);
    logic [31:0] mem[0:2**6-1];  // 0~15 : 0x00 ~ 0x0F => 0x10 * 4 = 0x40
    // 워드 하나당 크기는 4바이트, 총 워드는 16개(메모리 크기 16층) = 전체 메모리 크기 16*4 = 64바이트 (0x40)
    // 기본 값 64byte, 0824 테스트 수정 256byte

    logic [31:0] WData;

    //시뮬
    /* initial begin
        mem[2] = 2;
        mem[3] = 4;
        mem[4] = 8;
        mem[5] = -2;
        mem[6] = -4;
    end */


    always_ff @(posedge clk) begin
        if (we) mem[addr[31:2]] <= WData;
    end

    // Store
    always_comb begin
        WData = wData;
        case (funct3)
            3'b000: begin
                case (addr[1:0])
                    2'b00: WData = {mem[addr[31:2]][31:8], wData[7:0]};
                    2'b01: WData = {mem[addr[31:2]][31:16], wData[7:0], mem[addr[31:2]][7:0]};
                    2'b10: WData = {mem[addr[31:2]][31:24], wData[7:0], mem[addr[31:2]][15:0]};
                    2'b11: WData = {wData[7:0], mem[addr[31:2]][23:0]};
                endcase    
            end
            3'b001: begin
                case (addr[1])
                    1'b0: WData = {mem[addr[31:2]][31:16], wData[15:0]};
                    1'b1: WData = {wData[15:0], mem[addr[31:2]][15:0]};
                endcase
            end
        endcase
    end    

    // Store
/*     always_comb begin
        WData = wData;
        case (funct3)
            3'b000: begin
                case (addr[1:0])
                    2'b00: WData = {mem[addr[31:2]][31:8], wData[7:0]};
                    2'b01: WData = {mem[addr[31:2]][31:16], wData[15:8], mem[addr[31:2]][7:0]};
                    2'b10: WData = {mem[addr[31:2]][31:24], wData[23:16], mem[addr[31:2]][15:0]};
                    2'b11: WData = {wData[31:24], mem[addr[31:2]][23:0]};
                endcase    
            end
            3'b001: begin
                case (addr[1])
                    1'b0: WData = {mem[addr[31:2]][31:16], wData[15:0]};
                    1'b1: WData = {wData[31:16], mem[addr[31:2]][15:0]};
                endcase
            end
        endcase
    end */

    // Load
    always_comb begin
        rData =  mem[addr[31:2]];
        case (funct3)
            3'b000: begin // byte signed
                case (addr[1:0])
                    2'b00: rData = {{24{mem[addr[31:2]][7]}}, {mem[addr[31:2]][7:0]}};
                    2'b01: rData = {{24{mem[addr[31:2]][15]}}, {mem[addr[31:2]][15:8]}};
                    2'b10: rData = {{24{mem[addr[31:2]][23]}}, {mem[addr[31:2]][23:16]}};
                    2'b11: rData = {{24{mem[addr[31:2]][31]}}, {mem[addr[31:2]][31:24]}};
                endcase
            end
            3'b001: begin // half signed
                case (addr[1])
                    1'b0: rData = {{16{mem[addr[31:2]][15]}}, {mem[addr[31:2]][15:0]}};
                    1'b1: rData = {{16{mem[addr[31:2]][31]}}, {mem[addr[31:2]][31:16]}};
                endcase
            end 
            3'b100: begin // byte unsigned
                case (addr[1:0])
                    2'b00: rData = {24'b0, {mem[addr[31:2]][7:0]}};
                    2'b01: rData = {24'b0, {mem[addr[31:2]][15:8]}};
                    2'b10: rData = {24'b0, {mem[addr[31:2]][23:16]}};
                    2'b11: rData = {24'b0, {mem[addr[31:2]][31:24]}};
                endcase
            end 
            3'b101: begin // half unsigned
                case (addr[1])
                    1'b0: rData = {16'b0, mem[addr[31:2]][15:0]};
                    1'b1: rData = {16'b0, mem[addr[31:2]][31:16]};  
                endcase
            end
        endcase
    end
    /* assign rData = mem[addr[31:2]]; */
endmodule

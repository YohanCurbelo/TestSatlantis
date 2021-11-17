////////////////////////////////////////////////////////////////////////////////
// Company: SATELLOGIC S.A
//
// File: simple_dual_port_ram_two_clocks.v
//
// Description: 
//
// Simple Dual Port RAM with two different clocks, extracted from:
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2017_1/ug901-vivado-synthesis.pdf
// Author: David Caruso
//
////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

module simple_dual_port_ram_two_clocks #(
    parameter DATA_SIZE = 64,
    parameter MEM_SIZE = 1024
)(
    input                           CLKA,
    input                           CLKB,
    input                           ENA,
    input                           ENB,
    input                           WEA,
    input  [$clog2(MEM_SIZE)-1:0]   ADDRA,
    input  [$clog2(MEM_SIZE)-1:0]   ADDRB,
    input  [(DATA_SIZE-1):0]        DIA,
    output reg [(DATA_SIZE-1):0]    DOB);


reg [(DATA_SIZE-1):0] ram [(MEM_SIZE-1):0];

always @(posedge CLKA) begin
    if (ENA) begin
        if (WEA)
            ram[ADDRA] <= DIA;
    end
end

always @(posedge CLKB) begin
    if (ENB) begin
        DOB <= ram[ADDRB];
    end
end


`ifdef COCOTB_SIM
    initial begin
        $dumpfile("./sim_build/simple_dual_port_ram_two_clocks.vcd");
        $dumpvars (0,simple_dual_port_ram_two_clocks);
    end
`endif


endmodule

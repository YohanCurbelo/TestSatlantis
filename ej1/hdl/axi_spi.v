//------------------------------------------------------------------------------
// Company: Satellogic S.A
//
// File: axi_spi.v
// Description: 
//
// AXI-SPI device for new candidates
//
// Author: Andres Demski
//
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module axi_spi  #(
    parameter                               C_AXI_DATA_WIDTH=32,
    parameter                               C_AXI_ADDR_WIDTH=4
)(
    // AXI4-Lite Slave Port
    input                                   AXI_ACLK,
    input                                   AXI_ARESETN,
    input    [C_AXI_ADDR_WIDTH-1:0]         AXI_AWADDR,
    input                                   AXI_AWVALID,
    output                                  AXI_AWREADY,
    input    [C_AXI_DATA_WIDTH-1:0]         AXI_WDATA,
    input    [(C_AXI_DATA_WIDTH/8)-1:0]     AXI_WSTRB,
    input                                   AXI_WVALID,
    output                                  AXI_WREADY,
    output  [1:0]                           AXI_BRESP,
    output                                  AXI_BVALID,
    input                                   AXI_BREADY,
    input   [C_AXI_ADDR_WIDTH-1:0]          AXI_ARADDR,
    input                                   AXI_ARVALID,
    output                                  AXI_ARREADY,
    output  [C_AXI_DATA_WIDTH-1:0]          AXI_RDATA,
    output  [1:0]                           AXI_RRESP,
    output                                  AXI_RVALID,
    input                                   AXI_RREADY,

    output                                  MOSI,
    input                                   MISO,
    output                                  SCLK,
    output                                  CSn,

    output                                  INT
);

    wire     [C_AXI_DATA_WIDTH-1:0]     WDATA;
    wire     [C_AXI_DATA_WIDTH-1:0]     RDATA;
    wire     [C_AXI_ADDR_WIDTH -1:0]    RADDR;
    wire     [C_AXI_ADDR_WIDTH -1:0]    WADDR;
    wire                                WENA;
    wire                                RENA;

    axi_lite_slave_int #(
        .C_S_AXI_ADDR_WIDTH             (C_AXI_ADDR_WIDTH),
        .C_S_AXI_DATA_WIDTH             (C_AXI_DATA_WIDTH)
    ) axi_registers (
        .WDATA_O                        (WDATA),
        .RDATA_I                        (RDATA),
        .WENA_O                         (WENA),
        .RENA_O                         (RENA),
        .RADDR_O                        (RADDR),
        .WADDR_O                        (WADDR),
        .S_AXI_ACLK                     (AXI_ACLK),
        .S_AXI_ARESETN                  (AXI_ARESETN),
        .S_AXI_AWADDR                   (AXI_AWADDR),
        .S_AXI_AWVALID                  (AXI_AWVALID),
        .S_AXI_AWREADY                  (AXI_AWREADY),
        .S_AXI_WDATA                    (AXI_WDATA),
        .S_AXI_WSTRB                    (AXI_WSTRB),
        .S_AXI_WVALID                   (AXI_WVALID),
        .S_AXI_WREADY                   (AXI_WREADY),
        .S_AXI_BRESP                    (AXI_BRESP),
        .S_AXI_BVALID                   (AXI_BVALID),
        .S_AXI_BREADY                   (AXI_BREADY),
        .S_AXI_ARADDR                   (AXI_ARADDR),
        .S_AXI_ARVALID                  (AXI_ARVALID),
        .S_AXI_ARREADY                  (AXI_ARREADY),
        .S_AXI_RDATA                    (AXI_RDATA),
        .S_AXI_RRESP                    (AXI_RRESP),
        .S_AXI_RVALID                   (AXI_RVALID),
        .S_AXI_RREADY                   (AXI_RREADY)
    );

    //-------------------------------------------------------
    // Intanciar CORE AQUI!

    //-------------------------------------------------------

`ifdef COCOTB_SIM
    initial begin
        $dumpfile("sim_build/waveform.vcd");
        $dumpvars (0,axi_spi);
    end
`endif


endmodule

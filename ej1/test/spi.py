import cocotb
from cocotb.drivers.amba import AXI4LiteMaster
from cocotb.triggers import Timer, RisingEdge, FallingEdge, Edge
from cocotb.result import ReturnValue

class SPISlave(object):
    def __init__(self, dut):
        self.dut = dut
        self.cs = dut.CSn
        self.sclk = dut.SCLK
        self.mosi = dut.MOSI
        self.miso = dut.MISO
        self.monitor_buff = []
        cocotb.fork(self.monitor())
        cocotb.fork(self.loopback())

    @cocotb.coroutine
    def monitor(self):
        while True:
            data = 0
            yield FallingEdge(self.cs)
            for _ in range(8):
                yield RisingEdge(self.sclk)
                data = data << 1
                value = self.mosi.value.integer
                data |= value
            yield RisingEdge(self.cs)
            self.monitor_buff.append(data)

    @cocotb.coroutine
    def loopback(self):
        self.miso <= self.mosi.value
        while True:
            yield Edge(self.mosi)
            self.miso <= self.mosi.value

class SpiAxi (object):
    ADDR_TX = 0x0
    ADDR_RX = 0x4

    def __init__(self, dut):
        self.axi = AXI4LiteMaster(dut, "AXI", dut.AXI_ACLK)
        self.clk = dut.AXI_ACLK
        self.spi = SPISlave(dut)
        self.irq = dut.INT

    @cocotb.coroutine
    def send_recv(self, data):
        yield RisingEdge(self.clk)
        yield self.axi.write(self.ADDR_TX, data)
        yield RisingEdge(self.irq)
        read = yield self.axi.read(self.ADDR_RX)
        raise ReturnValue(read.integer)

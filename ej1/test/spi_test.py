
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge, Edge
from cocotb.result import TestFailure, TestError, ReturnValue, SimFailure, TestSuccess
from cocotb.utils import get_sim_time
from spi import SpiAxi

CLK_PERIOD = 10 # ns


@cocotb.coroutine
def Reset(dut):
    dut.AXI_ARESETN <=  0
    yield Timer(CLK_PERIOD * 10, units='ns')
    dut.AXI_ARESETN  <= 1
    yield Timer(CLK_PERIOD * 10, units='ns')
    yield RisingEdge(dut.AXI_ACLK)

@cocotb.test()
def loopback_test(dut):
    cocotb.fork(Clock(dut.AXI_ACLK, period=CLK_PERIOD, units='ns').start())
    yield Reset(dut)
    spi = SpiAxi(dut)

    to_be_send = [i for i in range(256)]
    for value in to_be_send:
        recv = yield spi.send_recv(value)
        if recv != value:
            raise TestFailure("Recived data is {} and it should be {}".format(recv, value))
        else:
            dut._log.info("send: {} recv: {} .... DATA OK".format(value, recv))

@cocotb.test()
def tx_reg_test(dut):
    cocotb.fork(Clock(dut.AXI_ACLK, period=CLK_PERIOD, units='ns').start())
    yield Reset(dut)
    spi = SpiAxi(dut)

    yield spi.axi.write(0x0,0xAA)
    read = yield spi.axi.read(0x0)

    if read != 0xAA:
        raise TestFailure("Error reading TX register")

@cocotb.test()
def spi_freq_test(dut):
    cocotb.fork(Clock(dut.AXI_ACLK, period=CLK_PERIOD, units='ns').start())
    yield Reset(dut)
    spi = SpiAxi(dut)

    yield spi.axi.write(0x0,0xAA)
    yield RisingEdge(dut.SCLK)
    t1 = get_sim_time(units='us')

    yield RisingEdge(dut.SCLK)
    t2 = get_sim_time(units='us')

    period = (t2-t1)/1000/1000
    freq = 1/period

    if freq != 1e6:
        s = "SPI SCLK bad frequence. It should be 1Mhz and it was {}MHz"
        raise TestFailure(s.format(freq/1000/1000))


@cocotb.test()
def endianness_test(dut):
    cocotb.fork(Clock(dut.AXI_ACLK, period=CLK_PERIOD, units='ns').start())
    yield Reset(dut)
    spi = SpiAxi(dut)

    yield spi.axi.write(0x0,0x55)
    data = 0
    for _ in range(8):
        yield RisingEdge(dut.SCLK)
        data = data << 1
        data |= dut.MOSI.value.integer

    if data != 0x55:
        raise TestFailure("Recived data should be 0x55 and it was %d" % data)


@cocotb.coroutine
def check_sequence(dut):
    f_cs = FallingEdge(dut.CSn)
    r_cs = RisingEdge(dut.CSn)
    r_sclk = RisingEdge(dut.SCLK)
    tgr_list = [f_cs, r_cs, r_sclk]

    tgr = yield tgr_list
    if tgr != f_cs:
        raise TestFailure("Falling Edge wasn't the first event")

    for _ in range(8):
        tgr = yield tgr_list
        if tgr != r_sclk:
            raise TestFailure("CS changed before than expected")

    tgr = yield tgr_list
    if tgr != r_cs:
        raise TestFailure("It's another SCLK than expected")

    raise TestSuccess("Sequence is OK")


@cocotb.test()
def sequence_test(dut):
    cocotb.fork(Clock(dut.AXI_ACLK, period=CLK_PERIOD, units='ns').start())
    yield Reset(dut)
    spi = SpiAxi(dut)
    cocotb.fork(check_sequence(dut))

    yield spi.axi.write(0x0,0x55)
    yield Timer(15, units='us')
    raise TestFailure("Timeout")






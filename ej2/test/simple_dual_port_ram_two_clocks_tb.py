import cocotb
import random

from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, ReadOnly
from cocotb.result import TestFailure, TestSuccess
from cocotb.binary import BinaryValue

from cocotb.utils import get_sim_time

CLK_PERIOD_A = 2
CLK_PERIOD_B = 4


@cocotb.test()
def simple_test(dut):
    """
        Simple test: it writes random values to all memory addresses and reads them back.
    """

    dut._log.info('Init Clocks')
    cocotb.fork(Clock(dut.CLKA, CLK_PERIOD_A, units='ns').start())
    cocotb.fork(Clock(dut.CLKB, CLK_PERIOD_B, units='ns').start())

    dut._log.info('Setup the initial state of signals')
    dut.ENA <= 1 # Always enable
    dut.ENB <= 1 # Always enable
    dut.WEA <= 0

    dut.ADDRA <= 0
    dut.ADDRB <= 0

    dut.DIA <= 0
    dut.DOB <= 0

    yield RisingEdge(dut.CLKA)
    yield RisingEdge(dut.CLKA)

    dut._log.info('Writing all addresses with random integer data')
    dut.ADDRA 	<=  0x00000
    data_tx      =  [0 for i in range(0,2**len(dut.ADDRA)-1)]
    for i in range(2**len(dut.ADDRA)-1):
        dut.WEA 	<= 1
        dut.ADDRA 	<= i
        data_tx[i] 	 = random.randint(0, 1024)
        dut.DIA 	<= data_tx[i]
        yield RisingEdge(dut.CLKA)
        dut._log.info("{} was written at address: {}" .format(dut.DIA.value, dut.ADDRA.value))
        dut.WEA 	<= 0
  
    dut._log.info('Reading all memory addresses')
    dut.ADDRB 	<= 0x00000
    for i in range(2**len(dut.ADDRB)-1):		
        dut.ADDRB   <=  i
        yield ReadOnly()        
                
        # It's a synch read memory, so you need 2 cycles to read the real data
        yield RisingEdge(dut.CLKB)
        yield RisingEdge(dut.CLKB)

        if (dut.DOB.value.integer != data_tx[i]):
            raise TestFailure("Data read at address {} is not correct. The data written was {} and {} was read" .format(dut.ADDRB.value, data_tx[i], dut.DOB.value))
        else:
            dut._log.info("Data at address {} is correct" .format(dut.ADDRB.value))
    
    raise TestSuccess("Test is OK")
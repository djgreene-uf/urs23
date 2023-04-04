import cocotb
import random
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer

@cocotb.coroutine
async def reset_dut(dut):
    dut.rst.value = 1
    for i in range(3):
        await FallingEdge(dut.clk_0)
    await RisingEdge(dut.clk_270)
    dut.rst.value = 0
    await RisingEdge(dut.clk_0)
    dut._log.info("Resetting")

@cocotb.coroutine
async def clock_in_gen(period, duty, delay, clk):
    high_time = period*duty
    low_time = period*(1-duty)
    high = Timer(high_time, units="ns")
    low = Timer(low_time, units="ns")
    period = high_time + low_time
    if (delay != 0):
        await Timer(delay, units="ns")
    while True:
        clk.value = 1
        await high
        clk.value = 0
        await low

@cocotb.test()
async def basic_test(dut):
    # Phase (between 0 and 3)
    phase_test = 3

    # Sample frequency in MHz
    clock_sample_freq = 250
    clock_sample_period = 1000/clock_sample_freq

    cocotb.start_soon(clock_in_gen(clock_sample_period, 0.5, 0, dut.clk_0))
    cocotb.start_soon(clock_in_gen(clock_sample_period, 0.5, clock_sample_period*0.25, dut.clk_90))
    cocotb.start_soon(clock_in_gen(clock_sample_period, 0.5, clock_sample_period*0.5, dut.clk_180))
    cocotb.start_soon(clock_in_gen(clock_sample_period, 0.5, clock_sample_period*0.75, dut.clk_270))

    await cocotb.start(reset_dut(dut))

    # MHz and ns
    clk_in_0_freq = 10
    clk_in_0_period = 1000/clk_in_0_freq
    phase_0 = 0.5 + (phase_test+1)*clock_sample_period*0.25

    await FallingEdge(dut.rst)

    cocotb.start_soon(clock_in_gen(clk_in_0_period, 0.5, phase_0, dut.d))

    dut._log.info("Sampling clock period: " + str(clock_sample_period) + " ns")

    for i in range(10):
        await RisingEdge(dut.phase_valid)
        phase_tag = dut.phase.value
        if (phase_tag != phase_test):
            dut._log.error("Should be " + str(phase_test) + " instead is " + str(phase_tag))



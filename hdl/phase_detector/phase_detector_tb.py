import cocotb
import random
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer

@cocotb.coroutine
async def reset_dut(dut):
    dut.rst.value = 1
    await FallingEdge(dut.clk_sample)
    dut.rst.value = 0
    await FallingEdge(dut.clk_sample)
    dut.log.info("Resetting")

@cocotb.coroutine
async def clock_in_gen(period, duty, phase, clk):
    high_time = period*duty
    low_time = period*(1-duty)
    high = Timer(high_time, units="ns")
    low = Timer(low_time, units="ns")
    period = high_time + low_time
    phase_delay = period * phase
    await Timer(phase_delay, units="ns")
    while True:
        clk.value = 1
        await high
        clk.value = 0
        await low

@cocotb.test()
async def basic_test(dut):
    # Sample frequency in MHz
    clock_sample_freq = 160
    clock_sample_period = 1000/clock_sample_freq
    clock_sample = Clock(dut.clk_sample, clock_sample_period, units="ns")
    # clock_sample = Clock(dut.clk_sample, 7.6923, units="ns")
    dut._log.info("hey")

    await cocotb.start(reset_dut(dut))

    cocotb.start_soon(clock_sample.start())

    phase_0 = 0
    phase_1 = 0.04

    # MHz and ns
    clk_in_freq = 5
    clk_in_period = 1000/clk_in_freq

    cocotb.start_soon(clock_in_gen(clk_in_period, 0.5, phase_0, dut.clk_in_0))
    cocotb.start_soon(clock_in_gen(clk_in_period, 0.5, phase_1, dut.clk_in_1))

    dut._log.info("Expected phase error: " + str(clk_in_period*(phase_1-phase_0)) + " ns")
    dut._log.info("Phase detector resolution: " + str(clock_sample_period) + " ns")

    for i in range(10):
        await RisingEdge(dut.phase_err_valid)
        phase_err_count = dut.phase_err.value
        dut._log.info("Received phase error count: " + str(phase_err_count))

        phase_err = phase_err_count*1000/clock_sample_freq
        if (int(phase_err) > clk_in_period*0.5):
            phase_err = -1*((clk_in_period) - phase_err)

        dut._log.info("Phase error: " + str(phase_err) + "ns")

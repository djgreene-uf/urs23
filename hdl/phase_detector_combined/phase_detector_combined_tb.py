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
async def clock_in_gen(period, duty, delay, clk, jitter=0):
    high_time = period*duty
    low_time = period*(1-duty)
    period = high_time + low_time
    if (delay != 0):
        await Timer(delay, units="ns")
    while True:
        clk.value = 1
        if jitter != 0:
            jitter_delay = random.randrange(-jitter, jitter+1, 1)/10
        else:
            jitter_delay = 0
        high = Timer(high_time+jitter_delay, units="ns")
        if jitter != 0:
            jitter_delay = random.randrange(-jitter, jitter+1, 1)/10
        else:
            jitter_delay = 0
        low = Timer(low_time+jitter_delay, units="ns")
        await high
        clk.value = 0
        await low

@cocotb.test()
async def basic_test(dut):
    # Sample frequency in MHz
    clk_sample_freq = 250
    clk_sample_period = 1000/clk_sample_freq

    cocotb.start_soon(clock_in_gen(clk_sample_period, 0.5, 0, dut.clk_0))
    cocotb.start_soon(clock_in_gen(clk_sample_period, 0.5, clk_sample_period*0.25, dut.clk_90))
    cocotb.start_soon(clock_in_gen(clk_sample_period, 0.5, clk_sample_period*0.5, dut.clk_180))
    cocotb.start_soon(clock_in_gen(clk_sample_period, 0.5, clk_sample_period*0.75, dut.clk_270))

    await cocotb.start(reset_dut(dut))

    # TODO：Allow to change delay with command line
    # MHz and ns
    # Try 0.5
    clk_in_0_freq = 0.1
    clk_in_0_period = 1000/clk_in_0_freq
    phase_0 = 3.2

    # Try 10.1 and 10.6
    clk_in_1_freq = 10
    clk_in_1_period = 1000/clk_in_1_freq
    phase_1 = 5.4

    # It is really this minus 1, but using this number for math purposes
    max_phase_count = (clk_sample_freq/clk_in_1_freq)

    await FallingEdge(dut.rst)

    cocotb.start_soon(clock_in_gen(clk_in_0_period, 0.5, phase_0, dut.clk_in_0, jitter=0))
    cocotb.start_soon(clock_in_gen(clk_in_1_period, 0.5, phase_1, dut.clk_in_1, jitter=0))

    dut._log.info("Expected phase error: " + str(phase_1-phase_0) + " ns")
    dut._log.info("Phase detector resolution: " + str(clk_sample_period/4) + " ns")

    phase_err_average = 0
    num_tests = 5

    for i in range(num_tests):
        await RisingEdge(dut.phase_tag_valid)
        phase_tag = dut.phase_tag.value

        # Increments on every clk 0 or "start" clock
        clk_0_count = (phase_tag >> 10) & 0x003f

        # Integer portion of count, number of full cycles between "start" and "stop"
        phase_err_count = (phase_tag >> 4) & (0x003f)

        # Fractional portions of count
        phase_err_start_frac = (phase_tag >> 2) & (0x0003)
        phase_err_stop_frac = (phase_tag) & (0x0003)

        dut._log.info("Received CLK 0 count: " + str(clk_0_count))
        dut._log.info("Received phase error count: " + str(phase_err_count))
        dut._log.info("Received start fraction: " + str(phase_err_start_frac))
        dut._log.info("Received stop fraction: " + str(phase_err_stop_frac))

        # Calculating phase error with fractional bits
        phase_err_count_frac = (phase_err_stop_frac*0.25 + phase_err_count) - (phase_err_start_frac*0.25)

        # Normalizing range from [0, max_phase_count-1] to [-(max_phase_count/2 - 1), (max_phase_count/2 - 1)]
        if (phase_err_count_frac >= 0.5*max_phase_count):
            phase_err_count_frac = phase_err_count_frac - max_phase_count

        # Converting to ns
        phase_err = (phase_err_count_frac/(clk_sample_freq)) * 1000

        phase_err_average += phase_err

        dut._log.info("Phase error: " + str(phase_err) + "ns")

    phase_err_average = phase_err_average/num_tests
    dut._log.info("Average phase error: " + str(phase_err_average) + "ns")
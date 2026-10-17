# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0


import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def fifo_smoke_test(dut):
    # Initialize inputs
    dut.clk.value = 0
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Reset
    await Timer(20, unit="ns")
    dut.rst_n.value = 1

    # Write 0xA5
    dut.ui_in.value = 0xA5
    dut.uio_in.value = 0b00000010  # write enable
    dut.clk.value = 0
    await Timer(5, unit="ns")
    dut.clk.value = 1
    await Timer(5, unit="ns")

    # Stop writing
    dut.uio_in.value = 0

    # Read enable
    dut.uio_in.value = 0b00000100
    dut.clk.value = 0
    await Timer(5, unit="ns")
    dut.clk.value = 1
    await Timer(5, unit="ns")

    # Select data output
    dut.uio_in.value = 0
    await Timer(5, unit="ns")

    dut._log.info("FIFO output: %s", dut.uo_out.value)


    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.

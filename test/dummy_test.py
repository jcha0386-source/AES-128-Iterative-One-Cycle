import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def run_verilog_tb(dut):
    """Dummy cocotb test to let the native Verilog testbench run"""
    cocotb.log.info("Handing execution over to the native Verilog testbench...")
    # Just wait a long time to let your Verilog tb finish its simulation loop
    await Timer(1000, units="ns")

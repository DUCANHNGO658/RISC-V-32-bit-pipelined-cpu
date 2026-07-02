# RISC-V-32-bit-pipelined-cpu
RISC-V 32-bit Pipelined Processor - Subset RV32I

- Pipeline registers fixed
- Updated hazard detect unit ( check lw ) and forwarding unit 
- Updated immediate calculation based on RISC_V architecture

-2/7/2026
Fixed the copy paste fault in register file 
Fixed the logic in hazard detection
Deleted the aluop in control unit (alu control already hanlded)
Updated the jal in control unit, top module, pipeline and 
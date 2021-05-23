-------------------------------------------------------
--! @file
--! @brief Integer unit pipelined data path
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library periscore32;
use periscore32.cpu_types.all;
use periscore32.memory_utils.all;

--! Pipelined data path able to execute
--! a subset of mips32r2 instructions.
--! Consists of classic 5 stage pipeline:
--! 1. Instruction fetch (IF)
--! 2. Instruction decode (ID)
--! 3. Execution (EX)
--! 4. Memory access (MEM)
--! 5. Results write back (WB)
--! Instruction subset supported:
--! - Arithmetic, logical, shift and rotate:
--!   + add, addi, addiu, addu, sub, subu
--!   + clo, clz
--!   + seb, seh 
--!   + slt, slti, sltiu, sltu
--!   + and, andi, nor, or, ori, xor, xori, lui
--!   + rotr, rotrv, sll, sllv, sra, srav, srl, srlv
--! - Memory:
--!   + lw, sw
--! - Branch and jump:
--!   + beq, j
--! This version does not include hazard control
--!
entity pipelined_datapath is
    port (
        clk : std_logic;
        
    ) ;
end pipelined_datapath ;

architecture rtl of pipelined_datapath is

    signal if_id : IF_ID;
    signal id_ex : ID_EX;
    signal ex_mem : EX_MEM;
    signal mem_wb : MEM_WB;

begin



end architecture ;
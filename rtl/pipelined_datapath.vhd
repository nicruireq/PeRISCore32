-------------------------------------------------------
--! @file
--! @brief Integer unit pipelined data path
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library periscore32;
use periscore32.cpu_types.all;
use periscore32.memory_utils.all;
use periscore32.cpu_components.all;

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

    -- segmentation registers
    signal pc : word;
    signal if_id : IF_ID;
    signal id_ex : ID_EX;
    signal ex_mem : EX_MEM;
    signal mem_wb : MEM_WB;

    -- intermediate signals
    signal pc_input : word;
    signal pc_plus4 : word;
    signal branch_target_address : word;
    signal fetched_instruction : word;


begin

    --===================
    -- IF Stage logic
    --===================

    -- Select PC register source
    with pcsrc select
        pc_input <= pc_plus4 when '0',
                    branch_target_address when others;
    
    -- Next instruction address 
    pc_plus4 <= std_logic_vector(
        unsigned(next_address_bytes) + unsigned(PC));

    instructions_cache : cache_L1
        port map(
            clk => clk,
            enable => '1',
            write_enable => '0',
            address => pc,
            data_in => (others => '0'),
            data_out => fetched_instruction
        ); 

    pc_update : process (clk)
    begin
        if rising_edge(clk) then
            pc <= pc_input;
        end if ;
    end process;

    if_id_update : process (clk)
    begin
        if rising_edge(clk) then
            if_id.pc <= pc;
            if_id.instruction <= fetched_instruction;
        end if;
    end process;

    --===================
    -- ID Stage logic
    --===================

    id_ex_update : process (clk)
    begin
        if rising_edge(clk) then
            id_ex.instruction <= if_id.instruction;
            id_ex.operand_A <= ;
            id_ex.operand_B <= ;
            id_ex.immediate <= ;
            id_ex.shift_amount <= ;
            id_ex.reg_write <= ;
            id_ex.alu_op <= ;
            id_ex.operandB_src <= ;
            id_ex.sel_alu_control <= ;
            id_ex.mem_read <= ;
            id_ex.mem_write <= ;
            id_ex.mem_to_reg <= ;
        end if ;
    end process ; -- id_ex_update

end architecture ;
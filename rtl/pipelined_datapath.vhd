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
    signal operand_A : word;
    signal operand_B : word;
    signal main_control_unit : control_unit_rom 
            := load_memory_from_file("microcode/control_unit.dat");
    signal main_control_signals : main_control_bus;
    

begin

    --===================
    -- IF Stage logic
    --===================

    -- Select PC register source
    with main_control_signals(pc_src) select
        pc_input <= pc_plus4 when '0',
                    branch_target_address when others;
    
    -- Next instruction address 
    pc_plus4 <= std_logic_vector(
        unsigned(next_address_bytes) + unsigned(PC));

    instructions_cache : direct_mapped_ICache
        port map(
            clk => clk,
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

    register_file port map(
        clk => clk,
        reg_write => reg_write,
        address_A => if_id.instruction(rs_h downto rs_l),
        address_B => if_id.instruction(rt_h downto rt_l),
        address_write => if_id.instruction(rd_h downto rd_l),
        data_in   => , -- lo que viene de WB
        operand_A => operand_A,
        operand_B => operand_B,
    )

    control_unit : process(if_id.instruction(opcode_h downto opcode_l))
    begin
        main_control_signals <= main_control_unit(
            to_integer(unsigned(
                if_id.instruction(opcode_h downto opcode_l)
            )));
    end process;

    -- branch and jump logic
    branch_unit : process(main_control_signals(jump))
    begin
        if main_control_signals(jump) then
            branch_target_address <= 
                if_id.pc(31 downto 28) &
                (if_id.instruction(instr_index_h downto instr_index_l) sll 2);
        else
            if main_control_signals(branch) then
                if operand_A = operand_B then
                    branch_target_address <=
                        -- immediato +- if_id.pc;
                else
                    branch_target_address <= if_id.pc;
                end if;
            else
                branch_target_address <= if_id.pc;
            end if;
        end if;
    end process;


    id_ex_update : process (clk)
    begin
        if rising_edge(clk) then
            id_ex.instruction <= if_id.instruction;
            id_ex.operand_A <= operand_A;
            id_ex.operand_B <= operand_B;
            -- immediate sign extension
            id_ex.immediate <=
                std_logic_vector(resize(
                    signed(if_id.instruction(imm_h downto imm_l)),
                    word_width
                ));
            -- shift amount zero extension
            id_ex.shift_amount <=
                std_logic_vector(resize(
                    unsigned(if_id.instruction(sa_h downto sa_l)),
                    word_width
                ));
            -- control signals
            id_ex.reg_write <= main_control_signals(reg_write);
            id_ex.alu_op <= main_control_signals(alu_op_h downto alu_op_l);
            id_ex.operandB_src <= main_control_signals(operandB_src);
            id_ex.sel_alu_control <= main_control_signals(sel_alu_control);
            id_ex.mem_read <= main_control_signals(mem_read);
            id_ex.mem_write <= main_control_signals(mem_write);
            id_ex.mem_to_reg <= main_control_signals(mem_to_reg);
        end if ;
    end process ; -- id_ex_update

end architecture ;
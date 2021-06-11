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
        clk : std_logic
        
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
    signal immediate_sign_extended : word;
    -- signals ex stage
    signal alu_control_SPECIAL : special_control_rom
            := load_memory_from_file("microcode/alu_control_special.dat");
    signal alu_control_not_class : alu_control_rom
            := load_memory_from_file("microcode/alu_control_not_class.dat");
    signal alu_not_class_signals : alu_control_bus;
    signal alu_SPECIAL_signals : special_control_bus;
    signal alu_control_signals : alu_control_bus;
    signal alu_input_A : word;
    signal alu_input_B : word;
    signal alu_result : word;
    -- signals mem stage
    signal data_from_dcache : word;
    -- signals wb stage
    signal data_from_wb : word;
    

begin

    --===================
    -- IF Stage logic
    --===================

    -- Select PC register source
    pc_input <= branch_target_address 
                when main_control_signals(pc_src) = '1'
                else pc_plus4;
    
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
            if_id.pc <= pc_plus4;
            if_id.instruction <= fetched_instruction;
        end if;
    end process;


    --===================
    -- ID Stage logic
    --===================

    id_register_file : register_file port map(
        clk => clk,
        reg_write => mem_wb.reg_write,
        address_A => if_id.instruction(rs_h downto rs_l),
        address_B => if_id.instruction(rt_h downto rt_l),
        address_write => mem_wb.instruction(rd_h downto rd_l),
        data_in   => data_from_wb,
        operand_A => operand_A,
        operand_B => operand_B
    );

    control_unit : process(if_id.instruction(opcode_h downto opcode_l))
    begin
        main_control_signals <= main_control_unit(
            to_integer(unsigned(
                if_id.instruction(opcode_h downto opcode_l)
            )));
    end process;

    -- immediate sign extension
    immediate_sign_extended <= std_logic_vector(resize(
        signed(if_id.instruction(imm_h downto imm_l)),
        word_width
    ));

    -- branch and jump logic
    branch_unit : process(main_control_signals(jump),
        if_id.pc(31 downto 28), 
        if_id.instruction(instr_index_h downto instr_index_l),
        operand_A, operand_B, if_id.pc, immediate_sign_extended)
    begin
        if main_control_signals(jump) = '1' then
            branch_target_address <= 
                if_id.pc(31 downto 28) &
                if_id.instruction(instr_index_h downto instr_index_l) & "00";
        else
            if main_control_signals(branch) = '1' then
                if operand_A = operand_B then
                    branch_target_address <=
                        std_logic_vector(unsigned(if_id.pc) 
                            + unsigned(immediate_sign_extended));
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
            id_ex.immediate <= immediate_sign_extended;
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


    --===================
    -- EX Stage logic
    --===================

    not_class_instructions : process(id_ex.alu_op)
    begin
        alu_not_class_signals <= alu_control_not_class(
            to_integer(unsigned(
                id_ex.alu_op
            )));
    end process;

    SPECIAL_instructions : process(id_ex.instruction(funct_h downto funct_l))
    begin
        alu_SPECIAL_signals <= alu_control_SPECIAL(
            to_integer(unsigned(
                id_ex.instruction(funct_h downto funct_l)
            )));
    end process;

    -- select control source for ALU
    alu_control_signals <= alu_not_class_signals when id_ex.sel_alu_control = '1'
                            else alu_SPECIAL_signals(spcon_h downto spcon_l);

    -- ALU operand A input selection
    alu_input_A <= id_ex.shift_amount when alu_SPECIAL_signals(operandA_src) = '1'
                    else id_ex.operand_A;

    -- ALU operand B input selection
    alu_input_B <= id_ex.immediate when id_ex.operandB_src = '1'
                    else id_ex.operand_B;

    ex_alu : alu port map(
        operand_A => alu_input_A,
        operand_B => alu_input_B,
        control => alu_control_signals,
        computation_out => alu_result,
        overflow_flag => open
    );

    ex_mem_update : process(clk)
    begin
        if rising_edge(clk) then
            ex_mem.instruction <= id_ex.instruction;
            ex_mem.alu_result <= alu_result;
            ex_mem.operand_B <= id_ex.operand_B;
            -- propagate control signals
            ex_mem.mem_read <= id_ex.mem_read;
            ex_mem.mem_write <= id_ex.mem_write;
            ex_mem.mem_to_reg <= id_ex.mem_to_reg;
            ex_mem.reg_write <= id_ex.reg_write;
        end if;
    end process;


    --===================
    -- MEM Stage logic
    --===================

    data_cache : direct_mapped_DCache port map(
        clk => clk,
        write_enable => ex_mem.mem_write,
        read_enable => ex_mem.mem_read,
        address => ex_mem.alu_result,
        select_type => OP_WORD,
        signed_unsigned => '0', -- don't care with words
        data_in  => ex_mem.operand_B,
        data_out  => data_from_dcache
    );

    mem_wb_update : process(clk)
    begin
        if rising_edge(clk) then
            mem_wb.instruction <= ex_mem.instruction;
            mem_wb.mem_data <= data_from_dcache;
            mem_wb.alu_result <= ex_mem.alu_result;
            mem_wb.mem_to_reg <= ex_mem.mem_to_reg;
            mem_wb.reg_write <= ex_mem.reg_write;
        end if;
    end process;


    --===================
    -- MEM Stage logic
    --===================

    data_from_wb <= mem_wb.mem_data when mem_wb.mem_to_reg = '1'
                    else mem_wb.alu_result;

end architecture ;
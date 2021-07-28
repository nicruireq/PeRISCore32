---------------------------------------------------------------------------------------------
--! @file   pipelined_datapath.vhd
--! @brief  Integer unit pipelined data path
--! @author Nicolas Ruiz Requejo
--! @details    Pipelined data path able to execute
--!             a subset of mips32r2 instructions.
--!             Consists of classic 5 stage pipeline:
--!             1. Instruction fetch (IF)
--!             2. Instruction decode (ID)
--!             3. Execution (EX)
--!             4. Memory access (MEM)
--!             5. Results write back (WB)
--!             Instruction subset supported:
--!             - Arithmetic, logical, shift and rotate:
--!               + add, addi, addiu, addu, sub, subu
--!               + slt, slti, sltiu, sltu
--!               + and, andi, nor, or, ori, xor, xori, lui
--!               + sll, sllv, sra, srav, srl, srlv
--!             - Memory:
--!               + lw, sw
--!             - Branch and jump:
--!               + beq, j
--!             This version includes hazard detection and management
--!
--!
--! @Copyright  SPDX-FileCopyrightText: 2020 Nicolas Ruiz Requejo nicolas.r.requejo@gmail.com
--!             SPDX-License-Identifier: CERN-OHL-S-2.0+
--!
--!             This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,
--!             INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A
--!             PARTICULAR PURPOSE. Please see the CERN-OHL-S v2 for applicable conditions.
--!
--!             Source location: https://github.com/nicruireq/PeRISCore32
--!
--!             As per CERN-OHL-S v2 section 4, should You produce hardware based on this
--!             source, You must where practicable maintain the Source Location visible
--!             on the external case and documentation of the PeRISCore32 or other products 
--!             you make using this source.
--!
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library periscore32;
use periscore32.cpu_types.all;
use periscore32.memory_utils.all;
use periscore32.cpu_components.all;


entity pipelined_datapath is
    generic (
        icache_instructions : string := "./images/e1.dat";  --! file with instructions to load in instruction cache (text file of binary lines)
        icache_tags : string := "./images/e1_tags.dat"; --! file with address tag slice for instruction cache (text file of binary lines)
        dcache_data : string := "./images/e1_data.dat" --! file with initial data to load in data cache (text file of binary lines)
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        stop_start : in std_logic;  --! when '0' the pipeline is frozen, when '1' the pipeline is running
        dcache_address : in word;   --! when pipeline is in stop mode use this port to read a data cache line
        dcache_out : out word   --! shows data at current selected data cache address
    ) ;
end pipelined_datapath ;

architecture rtl of pipelined_datapath is

    -- SEGMENTATION REGISTERS
    signal pc : word;
    signal if_id : IF_ID;
    signal id_ex : ID_EX;
    signal ex_mem : EX_MEM;
    signal mem_wb : MEM_WB;

    -- INTERMEDIATE SIGNALS
    -- IF STAGE
    signal pc_input : word;
    signal pc_plus4 : word;
    -- ID STAGE
    --! controls PC register writing for hazards
    signal stall : control_signal;
    --! controls IF/ID writing for hazards
    signal pc_write : control_signal;
    --! controls if NOP is needed in ID/EX for stalling
    signal if_id_write : control_signal;
    signal branch_target_address : word;
    signal fetched_instruction : word;
    signal operand_A : word;
    signal operand_B : word;
    --! ROM memory containing the microcode of the main control unit
    signal main_control_unit : control_unit_rom 
            := load_memory_from_file("microcode/control_unit.dat");
    --! Output control signals from main control unit in ID stage
    signal main_control_signals : main_control_bus;
    signal immediate_sign_extended : word;
    signal immediate_zero_extended : word;
    signal branch_offset : signed(word_width-1 downto 0);
    --! inputs operands to branch control unit, may be forwarded or not
    signal branch_operand_A, branch_operand_B : word;
    --! output control signals from  ID forwarding unit
    signal forward_branch_A, forward_branch_B : id_forward;
    -- SIGNALS EX STAGE
    --! ROM memory containing the microcode of the ALU control unit for SPECIAL 
    --! opcode class instructions
    signal alu_control_SPECIAL : special_control_rom
            := load_memory_from_file("microcode/alu_control_special.dat");
    --! ROM memory containing the microcode of the ALU control unit for 
    --! non-class opcode instructions
    signal alu_control_not_class : alu_control_rom
            := load_memory_from_file("microcode/alu_control_not_class.dat");
    --! Output control signals from ALU not class control unit
    signal alu_not_class_signals : alu_control_bus;
    --! Output control signals from ALU SPECIAL control unit
    signal alu_SPECIAL_signals : special_control_bus;
    --! Selected control signals from ALU SPECIAL or ALU not class
    signal alu_control_signals : alu_control_bus;
    --! current input A at EX stage or forwarded input
    signal opA_or_forwarded : word;
    --! current input B at EX stage or forwarded input
    signal opB_or_forwarded : word;
    --! final input A to ALU in EX
    signal alu_input_A : word;
    --! final input B to ALU in EX
    signal alu_input_B : word;
    signal alu_result : word;
    -- output control signals from  ex forwarding unit
    signal forward_A, forward_B : ex_forward;
    -- To determine if rd in ex forward unit is rd or rt
    signal ex_mem_is_rd_or_rt, mem_wb_is_rd_or_rt : register_index;
    -- signals mem stage
    signal data_from_dcache : word;
    -- output control signals from  mem forwarding unit
    signal forward_mem : mem_forward;
    -- data to be written in data cache
    signal data_to_mem : word;
    -- SIGNALS WB STAGE
    signal destination_register_address : 
        std_logic_vector(regfile_address_width-1 downto 0);
    signal data_from_wb : word;
    
    -- DEBUG SIGNALS
    signal dbg_dcache_read_enable : std_logic;
    signal dbg_dcache_address : word;

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
        generic map(
            data_image => icache_instructions,
            tags_image => icache_tags
        )
        port map(
            clk => clk,
            write_enable => '0',
            address => pc,
            data_in => (others => '0'),
            data_out => fetched_instruction
        ); 

    pc_update : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                --pc <= (others => '0');
                -- change base address .text segment to 0x00003000
                pc <= x"00003000";
            -- stop_start is only for debug
            elsif (stop_start = '1') and
                    (pc_write = '1') then
                pc <= pc_input;
            end if;
        end if;
    end process;

    if_id_update : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                clean_if_id(if_id);
            elsif (stop_start = '1') and
                    (if_id_write = '1') then
                if_id.pc <= pc_plus4;
                if_id.instruction <= fetched_instruction;
            end if;
        end if;
    end process;


    --===================
    -- ID Stage logic
    --===================

    hazard_detection_in_id : id_hazard_detection_unit port map(
        ex_mem_mem_read => ex_mem.mem_read,
        ex_mem_rt => ex_mem.instruction(rt_h downto rt_l),
        id_ex_mem_read => id_ex.mem_read,
        id_ex_reg_write => id_ex.reg_write,
        id_ex_operandB_src => id_ex.operandB_src,
        id_ex_rd => id_ex.instruction(rd_h downto rd_l),
        id_ex_rt => id_ex.instruction(rt_h downto rt_l),
        if_id_rs => if_id.instruction(rs_h downto rs_l),
        if_id_rt => if_id.instruction(rt_h downto rt_l),
        id_mem_write => main_control_signals(mem_write),
        id_branch => main_control_signals(branch),
        stall => stall,
        pc_write => pc_write,
        if_id_write => if_id_write
    );

    id_register_file : register_file port map(
        clk => clk,
        reg_write => mem_wb.reg_write,
        address_A => if_id.instruction(rs_h downto rs_l),
        address_B => if_id.instruction(rt_h downto rt_l),
        address_write => destination_register_address,
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

    -- immediate zero extension
    immediate_zero_extended <= std_logic_vector(resize(
        unsigned(if_id.instruction(imm_h downto imm_l)),
        word_width
    ));

    forward_unit_in_id : id_forward_unit port map(
        ex_mem_reg_write => ex_mem.reg_write,
        ex_mem_is_IType => ex_mem.is_IType,
        ex_mem_rd => ex_mem.instruction(rd_h downto rd_l),
        ex_mem_rt => ex_mem.instruction(rt_h downto rt_l),
        mem_wb_reg_write => mem_wb.reg_write,
        mem_wb_mem_read => mem_wb.mem_read,
        mem_wb_is_IType => mem_wb.is_IType,
        mem_wb_rd => mem_wb.instruction(rd_h downto rd_l),
        mem_wb_rt => mem_wb.instruction(rt_h downto rt_l),
        if_id_rs => if_id.instruction(rs_h downto rs_l),
        if_id_rt => if_id.instruction(rt_h downto rt_l),
        forward_A => forward_branch_A,
        forward_B => forward_branch_B
    );

    -- Forwarding MUX logic for branch unit
    branch_operand_A <= ex_mem.alu_result when forward_branch_A = "01" else
                        mem_wb.mem_data when forward_branch_A = "10" else
                        mem_wb.alu_result when forward_branch_A = "11" else
                        operand_A;
    
    branch_operand_B <= ex_mem.alu_result when forward_branch_B = "01" else
                        mem_wb.mem_data when forward_branch_B = "10" else
                        mem_wb.alu_result when forward_branch_B = "11" else
                        operand_B;

    --branch_offset <= signed(immediate_sign_extended) sll 2; --immediate_sign_extended(imm_shift_h downto imm_shitf_l) & "00"; -- not work
    -- align and extend immediate as branch offset to be added with pc
    branch_offset <= resize(signed(if_id.instruction(imm_h downto imm_l)) sll 2, word_width);

    -- branch and jump logic
    branch_unit : process(main_control_signals(jump),
        main_control_signals(branch),
        branch_offset, pc_plus4,
        if_id.pc(31 downto 28), 
        if_id.instruction(instr_index_h downto instr_index_l),
        branch_operand_A, branch_operand_B, if_id.pc, immediate_sign_extended)
    begin
        if main_control_signals(jump) = '1' then
            branch_target_address <= 
                if_id.pc(31 downto 28) &
                if_id.instruction(instr_index_h downto instr_index_l) & "00";
        else
            if main_control_signals(branch) = '1' then
                if branch_operand_A = branch_operand_B then
                    branch_target_address <=
                        std_logic_vector(unsigned(if_id.pc) + unsigned(branch_offset));
                else
                    branch_target_address <= pc_plus4; --if_id.pc;
                end if;
            else
                branch_target_address <= pc_plus4; --if_id.pc;
            end if;
        end if;
    end process;


    id_ex_update : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                clean_id_ex(id_ex);
            elsif stop_start = '1' then
                if stall = '1' then
                    -- insert NOP
                    clean_id_ex(id_ex);
                else
                    id_ex.instruction <= if_id.instruction;
                    id_ex.operand_A <= operand_A;
                    id_ex.operand_B <= operand_B;
                    -- zero extended: andi, ori, xori
                    -- sign extended: addi, addiu, slti, sltiu
                    if main_control_signals(imm_zero_sign) = '1' then
                        id_ex.immediate <= immediate_sign_extended;
                    else
                        id_ex.immediate <= immediate_zero_extended;
                    end if;
                    -- shift amount zero extension
                    id_ex.shift_amount <=
                        std_logic_vector(resize(
                            unsigned(if_id.instruction(sa_h downto sa_l)),
                            word_width
                        ));
                    -- control signals assignment
                    id_ex.reg_write <= main_control_signals(reg_write);
                    id_ex.alu_op <= main_control_signals(alu_op_h downto alu_op_l);
                    id_ex.operandB_src <= main_control_signals(operandB_src);
                    id_ex.sel_alu_control <= main_control_signals(sel_alu_control);
                    id_ex.mem_read <= main_control_signals(mem_read);
                    id_ex.mem_write <= main_control_signals(mem_write);
                    id_ex.mem_to_reg <= main_control_signals(mem_to_reg);
                    id_ex.dst_reg_rd_rt <= main_control_signals(dst_reg_rd_rt);
                end if;
            end if;
        end if ;
    end process ; -- id_ex_update


    --===================
    -- EX Stage logic
    --===================

    -- Distributed control unit for not class opcodes
    not_class_instructions : process(id_ex.alu_op)
    begin
        alu_not_class_signals <= alu_control_not_class(
            to_integer(unsigned(
                id_ex.alu_op
            )));
    end process;

    -- Distributed control unit for SPECIAL class opcodes
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
    alu_input_A <= id_ex.shift_amount when -- shiftamount passed only when id_ex instruction is R-Type
                        alu_SPECIAL_signals(operandA_src) = '1'
                            and id_ex.sel_alu_control = '0'
                    else opA_or_forwarded;

    -- ALU operand B input selection
    -- if id_ex has a store instruction must be bypassed the forwarded operand for B(rt)
    alu_input_B <= id_ex.immediate when id_ex.operandB_src = '1'
                    else opB_or_forwarded;

    -- EX stage forwarding logic

    -- mux to select between forwarded results or operand_A from ID/EX
    opA_or_forwarded <= ex_mem.alu_result when forward_A = "01" else
                        mem_wb.alu_result when forward_A = "10" else
                        mem_wb.mem_data when forward_A = "11" else
                        id_ex.operand_A;

    -- mux to select between forwarded results or operand_B from ID/EX
    opB_or_forwarded <= ex_mem.alu_result when forward_B = "01" else
                        mem_wb.alu_result when forward_B = "10" else
                        mem_wb.mem_data when forward_B = "11" else
                        id_ex.operand_B;

    -- If instruction in MEM or WB stage is I-Type register writable
    -- pass rt field of ex_mem and/or mem_wb to ex forward unit rd inputs
    ex_mem_is_rd_or_rt <= ex_mem.instruction(rt_h downto rt_l) when
                            ex_mem.is_IType = '1' else
                                ex_mem.instruction(rd_h downto rd_l);
    
    mem_wb_is_rd_or_rt <= mem_wb.instruction(rt_h downto rt_l) when
                            mem_wb.is_IType = '1' else
                                mem_wb.instruction(rd_h downto rd_l);

    forward_unit_ex : ex_forward_unit port map(
        ex_mem_reg_write => ex_mem.reg_write,
        ex_mem_rd => ex_mem_is_rd_or_rt,
        mem_wb_reg_write => mem_wb.reg_write,
        mem_wb_mem_read => mem_wb.mem_read,
        mem_wb_rd => mem_wb_is_rd_or_rt,
        mem_wb_rt => mem_wb.instruction(rt_h downto rt_l),
        id_ex_rs => id_ex.instruction(rs_h downto rs_l),
        id_ex_rt => id_ex.instruction(rt_h downto rt_l),
        forward_A => forward_A,
        forward_B => forward_B
    );

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
            if reset = '1' then
                clean_ex_mem(ex_mem);
            elsif stop_start = '1'then
                ex_mem.instruction <= id_ex.instruction;
                ex_mem.alu_result <= alu_result;
                --ex_mem.operand_B <= id_ex.operand_B; -- ERROR
                ex_mem.operand_B <= opB_or_forwarded;
                -- propagate control signals
                ex_mem.is_IType <= id_ex.operandB_src;
                ex_mem.mem_read <= id_ex.mem_read;
                ex_mem.mem_write <= id_ex.mem_write;
                ex_mem.mem_to_reg <= id_ex.mem_to_reg;
                ex_mem.reg_write <= id_ex.reg_write;
                ex_mem.dst_reg_rd_rt <= id_ex.dst_reg_rd_rt;
            end if;
        end if;
    end process;


    --===================
    -- MEM Stage logic
    --===================

    -- DEBUG
    dbg_dcache_read_enable <= ex_mem.mem_read when stop_start = '1'
                                else '1';
    dbg_dcache_address <= ex_mem.alu_result when stop_start = '1'
                            else dcache_address;
    -------------------------------

    -- MEM forward logic
    data_to_mem <= mem_wb.alu_result when forward_mem = "01" else
                    mem_wb.mem_data when forward_mem = "10" else
                    ex_mem.operand_B;

    forward_unit_mem : mem_forward_unit port map(
        ex_mem_write => ex_mem.mem_write,
        ex_mem_rt => ex_mem.instruction(rt_h downto rt_l),
        mem_wb_rd => mem_wb.instruction(rd_h downto rd_l),
        mem_wb_rt => mem_wb.instruction(rt_h downto rt_l),
        mem_wb_reg_write => mem_wb.reg_write,
        mem_wb_mem_read => mem_wb.mem_read,
        mem_wb_is_IType => mem_wb.is_IType,
        forward_mem => forward_mem
    );

    data_cache : direct_mapped_DCache 
        generic map(data_image => dcache_data)
        port map(
            clk => clk,
            write_enable => ex_mem.mem_write,
            read_enable => dbg_dcache_read_enable, --ex_mem.mem_read,
            address => dbg_dcache_address, --ex_mem.alu_result,
            select_type => OP_WORD,
            signed_unsigned => '0', -- don't care with words
            data_in  => data_to_mem,
            data_out  => data_from_dcache
        );

    -- DEBUG
    dcache_out <= data_from_dcache;
    -------------------------------

    mem_wb_update : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                clean_mem_wb(mem_wb);
            elsif stop_start = '1' then
                mem_wb.instruction <= ex_mem.instruction;
                mem_wb.mem_data <= data_from_dcache;
                mem_wb.alu_result <= ex_mem.alu_result;
                mem_wb.is_IType <= ex_mem.is_IType;
                mem_wb.mem_read <= ex_mem.mem_read;
                mem_wb.mem_to_reg <= ex_mem.mem_to_reg;
                mem_wb.reg_write <= ex_mem.reg_write;
                mem_wb.dst_reg_rd_rt <= ex_mem.dst_reg_rd_rt;
            end if;
        end if;
    end process;


    --===================
    -- WB Stage logic
    --===================

    -- pass rd for R instructions
    -- pass rt for I instructions that write in register file
    destination_register_address <= mem_wb.instruction(rt_h downto rt_l) when mem_wb.dst_reg_rd_rt = '1'
                                    else mem_wb.instruction(rd_h downto rd_l);

    -- pass mem data for lw
    -- pass alu result for another 
    data_from_wb <= mem_wb.mem_data when mem_wb.mem_to_reg = '1'
                    else mem_wb.alu_result;

end architecture ;
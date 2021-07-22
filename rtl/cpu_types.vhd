-------------------------------------------------------
--! @file   cpu_types.vhd
--! @brief Type and constant definitions for
--!        PeRISCore32
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library periscore32;

package cpu_types is

    --! enumerated type to difference between
    --! operand types allowed by the cpu
    type operand_type is (OP_BYTE, OP_HALF, OP_WORD);
    --! most significant bit in a byte
    constant byte_msb : integer := 7;
    --! most significant bit in a half word
    constant halfword_msb : integer := 15;
    --! width of instruction operation codes
    constant opcode_width : integer := 6;
    --! width in bits of shift amount field 
    --! of R type instruction word
    constant shift_amount_bits : integer := 5;
    --! width in bits of control signal input to ALU
    constant alu_control_width : integer := 5;
    --! number of bit in a word
    constant word_width : integer := 32;
    --! number of bits in a halfword
    constant half_width : integer := 16;
    --! number of bits in a byte
    constant byte_width : integer := 8;
    --! number of registers in register file
    constant registers_amount : integer := 32;
    --! number of bits in register file address
    constant regfile_address_width : integer := 5;

    subtype byte is std_logic_vector(byte_width-1 downto 0);
    subtype word is std_logic_vector(word_width-1 downto 0);
    subtype halfword is std_logic_vector(half_width-1 downto 0);
    subtype control_signal is std_logic;
    subtype alu_control is std_logic_vector(3 downto 0) ;
    subtype register_index is std_logic_vector(regfile_address_width-1 downto 0);

    constant next_address_bytes : word := x"00000004";
    --! constant for index of register zero
    constant zero : register_index := "00000";

    --! type representing ALU's control words
    subtype alu_opcode is std_logic_vector(alu_control_width-1 downto 0);
    constant alu_add : alu_opcode := "00000";
    constant alu_add_unsigned : alu_opcode := "00001";
    constant alu_sub : alu_opcode := "00010";
    constant alu_sub_unsigned : alu_opcode := "00011";
    constant alu_set_on_less : alu_opcode := "00100";
    constant alu_set_on_less_unsigned : alu_opcode := "00101";
    constant alu_and : alu_opcode := "00110";
    constant alu_lui : alu_opcode := "00111";
    constant alu_nor : alu_opcode := "01000";
    constant alu_or : alu_opcode := "01001";
    constant alu_xor : alu_opcode := "01010";
    constant alu_sll : alu_opcode := "01011";
    constant alu_slr : alu_opcode := "01100";
    constant alu_sra : alu_opcode := "01101";
    constant alu_count_leading_ones : alu_opcode := "01110";
    constant alu_count_leading_zeros : alu_opcode := "01111";
    constant alu_extend_byte : alu_opcode := "10000";
    constant alu_extend_half : alu_opcode := "10001";

    -------------------------------------------------------
    --      PIPELINE REGISTERS 
    -------------------------------------------------------

    --! most significant bit of opcode field in instruction word
    constant opcode_h : integer := 31;
    --! less significant bit of opcode field in instruction word
    constant opcode_l : integer := 26;
    --! most significant bit of rs field in instruction word (R-Type, I-Type)
    constant rs_h : integer := 25;
    --! less significant bit of rs field in instruction word (R-Type, I-Type)
    constant rs_l : integer := 21;
    --! most significant bit of rt field in instruction word (R-Type, I-Type)
    constant rt_h : integer := 20;
    --! less significant bit of rt field in instruction word (R-Type, I-Type)
    constant rt_l : integer := 16;
    --! most significant bit of immediate field in instruction word (I-Type)
    constant imm_h : integer := 15;
    --! less significant bit of immediate field in instruction word (I-Type)
    constant imm_l : integer := 0;
    --! most significant bit of instruction index field in instruction word (J-Type)
    constant instr_index_h : integer := 25;
    --! less significant bit of instruction index field in instruction word (J-Type)
    constant instr_index_l : integer := 0;
    --! most significant bit of rd field in instruction word (R-Type)
    constant rd_h : integer := 15;
    --! less significant bit of rd field in instruction word (R-Type)
    constant rd_l : integer := 11;
    --! most significant bit of shift amount field in instruction word (R-Type)
    constant sa_h : integer := 10;
    --! less significant bit of shift amount field in instruction word (R-Type)
    constant sa_l : integer := 6;
    --! most significant bit of function field in instruction word (R-Type)
    constant funct_h : integer := 5;
    --! less significant bit of function field in instruction word (R-Type)
    constant funct_l : integer := 0;
    --! sign extended immediate shifted 2 bits left MSB (for branches)
    constant imm_shift_h : integer := 29;
    --! sign extended immediate shifted 2 bits left LSB (for branches)
    constant imm_shitf_l : integer := 0;
    

    --! Pipeline register of 
    --! Instruction Fetch to Decode stages
    type IF_ID is record
        pc : word;
        instruction : word;
    end record IF_ID;
    
    --! Pipeline register of 
    --! Instruction Decode to Execution stages
    type ID_EX is record
        instruction : word;
        operand_A : word;
        operand_B : word;
        -- sign extended immediate
        immediate : word;
        -- zero extended shift amount
        shift_amount : word;
        -- signals in id/ex register
        --pc_src : control_signal;  -- HAY QUE QUITARLA? ES CONSUMIDA EN ESTA ETAPA?
        reg_write : control_signal;
        --branch : control_signal;  -- used in ID
        --jump : control_signal;    -- used in ID
        alu_op : alu_control;
        operandB_src : control_signal;
        sel_alu_control : control_signal;
        mem_read : control_signal;
        mem_write : control_signal;
        mem_to_reg : control_signal;
        dst_reg_rd_rt : control_signal;
    end record ID_EX;

    --! Pipeline register of 
    --! Instruction Execution to Memory stages
    type EX_MEM is record
        instruction : word;
        --mem_address : word;
        alu_result : word;
        operand_B : word;   -- for store instruction
        -- signals in ex/mem register
        is_IType : control_signal;  -- to determine if instruction is I-Type
        mem_read : control_signal;
        mem_write : control_signal;
        mem_to_reg : control_signal;
        reg_write : control_signal;
        dst_reg_rd_rt : control_signal;
    end record EX_MEM;

    --! Pipeline register of 
    --! Instruction Memory to Writeback stages
    type MEM_WB is record
        instruction : word;
        mem_data : word;
        alu_result : word;
        -- signals in ex/mem register
        is_IType : control_signal;  -- to determine if instruction is I-Type
        mem_read : control_signal;  -- keep to mem forward logic
        mem_to_reg : control_signal;
        reg_write : control_signal;
        dst_reg_rd_rt : control_signal;
    end record MEM_WB;

    -- Procedures to clean pipeline registers
    procedure clean_if_id(signal if_id_reg : out IF_ID);
    procedure clean_id_ex(signal id_ex_reg : out ID_EX);
    procedure clean_ex_mem(signal ex_mem_reg : out EX_MEM);
    procedure clean_mem_wb(signal mem_wb_reg : out MEM_WB);

    -------------------------------------------------------
    --      CONTROL SIGNALS TYPES 
    -------------------------------------------------------

    -- NOTE: We need a lot of types definition because the lack
    -- of generic types, function list, generics in functions
    -- in vivado synthesis (vhdl-2008 features)

    --! Total sum of width in bits from main control signals
    constant width_control_signals : integer := 15;
    --! Type representing the bus formed by the control 
    --! signals of the main control unit
    subtype main_control_bus 
        is std_logic_vector(width_control_signals-1 downto 0);
    --! Width in bits of alu_op control signal. This bus
    --! is the input of ALU control unit
    constant alu_op_width : integer := 4;
    --! Type representing input control signals to the ALU
    subtype alu_control_bus 
        is std_logic_vector(alu_control_width-1 downto 0);
    --! Width in bits of function instruction field . This bus
    --! is the input of SPECIAL ALU control unit
    constant function_width : integer := 6;
    --! Type representing output bus width of the SPECIAL
    --! ALU control unit (ALU control bus signals + operandA_src signal)
    subtype special_control_bus 
        is std_logic_vector(alu_control_width downto 0);

    -- Constants for place of control signal bits
    -- in main_control_bus
    constant pc_src : integer := 14;
    constant reg_write : integer := 13;
    constant branch : integer := 12;
    constant jump : integer := 11;
    constant alu_op_h : integer := 10;
    constant alu_op_l : integer := 7;
    constant operandB_src : integer := 6;
    constant sel_alu_control : integer := 5;
    constant mem_read : integer := 4;
    constant mem_write : integer := 3;
    constant mem_to_reg : integer := 2;
    constant dst_reg_rd_rt : integer := 1;
    constant imm_zero_sign : integer := 0;

    -- Constants for place of control signal bits
    -- in SPECIAL alu control unit
    constant operandA_src : integer := 0;
    -- lsb of control in output bus of special 
    -- alu control unit
    constant spcon_l : integer := 1;
    -- msb of control in output bus of special 
    -- alu control unit
    constant spcon_h : integer := 5;

    -------------------------------------------------------
    --      FORWARDING AND HAZARD TYPES
    -------------------------------------------------------

    --! Type of output control signals from id forward unit
    --! that control forwarding MUXs in ID stage
    subtype id_forward is std_logic_vector(1 downto 0);
    --! Type of output control signals from ex forward unit
    --! that control forwarding MUXs in EX stage
    subtype ex_forward is std_logic_vector(1 downto 0);
    --! Type of output control signals from mem forward unit
    --! that control forwarding MUXs in MEM stage
    subtype mem_forward is std_logic_vector(1 downto 0);

end package ;

package body cpu_types is

    -- Procedures to clean pipeline registers
    procedure clean_if_id(signal if_id_reg : out IF_ID) is
    begin
        if_id_reg.pc <= (others => '0');
        if_id_reg.instruction <= (others => '0');
    end procedure;

    procedure clean_id_ex(signal id_ex_reg : out ID_EX) is
    begin
        id_ex_reg.instruction <= (others => '0');
        id_ex_reg.operand_A <= (others => '0');
        id_ex_reg.operand_B <= (others => '0');
        id_ex_reg.immediate <= (others => '0');
        id_ex_reg.shift_amount <= (others => '0');
        id_ex_reg.reg_write <= '0';
        id_ex_reg.alu_op <= (others => '0');
        id_ex_reg.operandB_src <= '0';
        id_ex_reg.sel_alu_control <= '0';
        id_ex_reg.mem_read <= '0';
        id_ex_reg.mem_write <= '0';
        id_ex_reg.mem_to_reg <= '0';
        id_ex_reg.dst_reg_rd_rt <= '0';
    end procedure;

    procedure clean_ex_mem(signal ex_mem_reg : out EX_MEM) is
    begin
        ex_mem_reg.instruction <= (others => '0');
        ex_mem_reg.alu_result <= (others => '0');
        ex_mem_reg.operand_B <= (others => '0');
        ex_mem_reg.is_IType <= '0';
        ex_mem_reg.mem_read <= '0';
        ex_mem_reg.mem_write <= '0';
        ex_mem_reg.mem_to_reg <= '0';
        ex_mem_reg.reg_write <= '0';
        ex_mem_reg.dst_reg_rd_rt <= '0';
    end procedure;

    procedure clean_mem_wb(signal mem_wb_reg : out MEM_WB) is
    begin
        mem_wb_reg.instruction <= (others => '0');
        mem_wb_reg.mem_data <= (others => '0');
        mem_wb_reg.alu_result <= (others => '0');
        mem_wb_reg.is_IType <= '0';
        mem_wb_reg.mem_read <= '0';
        mem_wb_reg.mem_to_reg <= '0';
        mem_wb_reg.reg_write <= '0';
        mem_wb_reg.dst_reg_rd_rt <= '0';
    end procedure;

end package body;
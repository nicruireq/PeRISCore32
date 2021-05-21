-------------------------------------------------------
--! @file   cpu_types.vhd
--! @brief Type and constant definitions for
--!        PeRISCore32
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package cpu_types is

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

    subtype word is std_logic_vector(word_width-1 downto 0);
    subtype halfword is std_logic_vector(half_width-1 downto 0);
    subtype control_signal is std_logic;
    subtype alu_control is std_logic_vector(2 downto 0) ;

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
    constant funct_h : integer := 6;
    --! less significant bit of function field in instruction word (R-Type)
    constant funct_l : integer := 0;
    

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
        immediate : halfword;
        -- signals in id/ex register
        pc_src : control_signal;
        reg_write : control_signal;
        --branch : control_signal;  -- used in ID
        --jump : control_signal;    -- used in ID
        alu_op : alu_control;
        alu_src : control_signal;
        mem_read : control_signal;
        mem_write : control_signal;
        mem_to_reg : control_signal;
    end record ID_EX;

    --! Pipeline register of 
    --! Instruction Execution to Memory stages
    type EX_MEM is record
        instruction : word;
        mem_address : word;
        alu_result : word;
        -- signals in ex/mem register
        mem_read : control_signal;
        mem_write : control_signal;
        mem_to_reg : control_signal;
    end record EX_MEM;

    --! Pipeline register of 
    --! Instruction Memory to Writeback stages
    type MEM_WB is record
        instruction : word;
        mem_data : word;
        alu_result : word;
        -- signals in ex/mem register
        mem_to_reg : control_signal;
    end record MEM_WB;

    -------------------------------------------------------
    --      CONTROL SIGNALS TYPES 
    -------------------------------------------------------

    --! Total sum of width in bits from main control signals
    constant width_control_signals : integer := 13;
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

end package ;
-------------------------------------------------------
--! @file   cpu_components.vhd
--! @brief Components definitions for
--!        PeRISCore32
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library periscore32;
use periscore32.cpu_types.all;

package cpu_components is
    
    component direct_mapped_DCache is
        generic(
            address_bits : integer := 32; --! width in bits of input address
            index_width : integer := 8; --! number of lines of cache index
            block_size : integer := 32; --! size of cache block
            byte_select : integer := 2; --! number of bits to select byte in each block
            data_image : string := "./images/dcache_img1.dat" --! path to file with initial content
        );
        port (
            clk : in std_logic;
            write_enable : in std_logic;
            read_enable : in std_logic;
            address : in word;
            select_type : in operand_type;   --! Allows load/store of byte, halfword and word
            signed_unsigned : in std_logic; --! Allows to select for signed or unsigned byte/half
            data_in : in word;
            data_out : out word
            --hit_miss : out std_logic
        );
    end component ;

    component direct_mapped_ICache is
        generic(
            address_bits : integer := 32; --! width in bits of input address
            index_width : integer := 8; --! number of lines of cache index
            block_size : integer := 32; --! size of cache block
            byte_select : integer := 2; --! number of bits to select byte in each block
            data_image : string := "./images/icache_img1.dat"; --! path to file with initial content
            tags_image : string    --! path to file with tags content
        );
        port (
            clk : in std_logic;
            write_enable : in std_logic;
            address : in word;
            data_in : in word;
            data_out : out word
        );
    end component ;

    component alu is
        generic (
            data_width : integer := 32;
            alu_control_width : integer := 5
        );
        port (
            operand_A : in std_logic_vector(data_width-1 downto 0);
            operand_B : in std_logic_vector(data_width-1 downto 0);
            control : in std_logic_vector(alu_control_width-1 downto 0);
            computation_out : out std_logic_vector(data_width-1 downto 0);
            overflow_flag : out std_logic
        ) ;
    end component;

    component register_file is
        generic (
            registers : integer := registers_amount;
            register_width : integer := word_width;
            address_width : integer := regfile_address_width
        );
        port (
            clk : in std_logic;
            reg_write : in std_logic;
            address_A : in std_logic_vector(address_width-1 downto 0);
            address_B : in std_logic_vector(address_width-1 downto 0);
            address_write : in std_logic_vector(address_width-1 downto 0);
            data_in   : in word;
            operand_A : out word;
            operand_B : out word
        );
    end component;

    component ex_forward_unit is
        port (
            ex_mem_reg_write : in control_signal;
            ex_mem_rd : in register_index;
            mem_wb_reg_write : in control_signal;
            mem_wb_mem_read : in control_signal;
            mem_wb_rd : in register_index;
            mem_wb_rt : in register_index;
            id_ex_rs : in register_index;
            id_ex_rt : in register_index;
            forward_A : out ex_forward;
            forward_B : out ex_forward
        );
    end component;

    component mem_forward_unit is
        port (
            ex_mem_write : in control_signal;
            ex_mem_rt : in register_index;
            mem_wb_rd : in register_index;
            mem_wb_rt : in register_index;
            mem_wb_reg_write : in control_signal;
            mem_wb_mem_read : in control_signal;
            forward_mem : out mem_forward
        );
    end component;

    component id_hazard_detection_unit is
        port (
            id_ex_mem_read : in control_signal;
            id_ex_reg_write : in control_signal;
            id_ex_operandB_src : in control_signal;
            id_ex_rd : in register_index;
            id_ex_rt : in register_index;
            if_id_rs : in register_index;
            if_id_rt : in register_index;
            id_mem_write : in control_signal; --! to detect a sw being decoded in ID stage
            id_branch : in control_signal;  --! to detect a beq being decoded in ID stage
            stall : out control_signal;
            pc_write : out control_signal;
            if_id_write : out control_signal
        );
    end component;

    component pipelined_datapath is
        generic (
            icache_instructions : string := "./images/"
        );
        port (
            clk : std_logic;
            reset : std_logic
        ) ;
    end component ;

end package ;

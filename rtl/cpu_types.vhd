
library ieee;
use ieee.std_logic_1164.all;

package cpu_types is

    constant byte_msb : integer := 7;
    constant halfword_msb : integer := 15;

    subtype alu_opcode is std_logic_vector(4 downto 0);
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

end package ;
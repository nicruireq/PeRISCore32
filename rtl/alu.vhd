library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library periscore32;
use periscore32.cpu_types.all;

entity alu is
    generic (data_width : integer := 32);
    port (
        operand_A : in std_logic_vector(data_width-1 downto 0);
        operand_B : in std_logic_vector(data_width-1 downto 0);
        control : in std_logic_vector(alu_control_width-1 downto 0);
        computation_out : out std_logic_vector(data_width-1 downto 0);
        zero_flag : out std_logic;
        overflow_flag : out std_logic
    ) ;
end alu;
 
architecture behavioural of alu is
    -- needs one more bit to check overflow
    signal intermediate_out : std_logic_vector(data_width downto 0);
    signal temp_A, temp_B : std_logic_vector(data_width downto 0);
begin

    temp_A <= operand_A(data_width-1) & operand_A;
    temp_B <= operand_B(data_width-1) & operand_B;

    computations : process( operand_A, operand_B, control, temp_A, temp_B )
    begin
        case( control ) is
        
            when alu_add =>
                intermediate_out <= std_logic_vector(signed(temp_A) + signed(temp_B));
                if intermediate_out(data_width) /= intermediate_out(data_width-1) then
                    overflow_flag <= '1';
                else 
                    overflow_flag <= '0';
                end if ;
            when alu_add_unsigned =>
                intermediate_out <= std_logic_vector(unsigned(temp_A) + unsigned(temp_B));
            when alu_sub =>
                intermediate_out <= std_logic_vector(signed(temp_A) - signed(temp_B));
                if intermediate_out(data_width) /= intermediate_out(data_width-1) then
                    overflow_flag <= '1';
                else 
                    overflow_flag <= '0';
                end if ;
            when alu_sub_unsigned =>
                intermediate_out <= std_logic_vector(unsigned(temp_A) - unsigned(temp_B));
            when alu_set_on_less =>
                if signed(operand_A) < signed(operand_B) then
                    intermediate_out(data_width downto 1) <= (others => '0');
                    intermediate_out(0) <= '1';
                else
                    intermediate_out <= (others => '0');
                end if ;
            when alu_set_on_less_unsigned =>
                if unsigned(operand_A) < unsigned(operand_B) then
                    intermediate_out(data_width downto 1) <= (others => '0');
                    intermediate_out(0) <= '1';
                else
                    intermediate_out <= (others => '0');
                end if ;
            when alu_and =>
                intermediate_out(data_width-1 downto 0) <= operand_A and operand_B;
            when alu_lui =>
                intermediate_out(data_width-1 downto data_width/2) <= operand_B(halfword_msb downto 0);
                intermediate_out(halfword_msb downto 0) <= (others => '0');
            when alu_nor =>
                intermediate_out(data_width-1 downto 0) <= operand_A nor operand_B;
            when alu_or =>
                intermediate_out(data_width-1 downto 0) <= operand_A or operand_B;
            when alu_xor =>
                intermediate_out(data_width-1 downto 0) <= operand_A xor operand_B;
            when alu_sll =>
                -- shift left logical
                -- Here operand_B is rt and operand_A is shift amount or rs
                intermediate_out(data_width-1 downto 0) <= std_logic_vector(unsigned(operand_B) sll to_integer(unsigned(operand_A(shift_amount_bits-1 downto 0))));
            when alu_slr =>
                -- shift right logical
                -- Here operand_B is rt and operand_A is shift amount or rs
                intermediate_out(data_width-1 downto 0) <= std_logic_vector(unsigned(operand_B) srl to_integer(unsigned(operand_A(shift_amount_bits-1 downto 0))));
            when alu_sra =>
                -- shift right arithmetic
                -- Here operand_B is rt and operand_A is shift amount or rs
                -- VHDL 2008 only:
                --intermediate_out(data_width-1 downto 0) <= std_logic_vector(signed(operand_B) sra to_integer(unsigned(operand_A(shift_amount_bits-1 downto 0))));
                intermediate_out(data_width-1 downto 0) <= std_logic_vector(shift_right(signed(operand_B), to_integer(unsigned(operand_A(shift_amount_bits-1 downto 0)))));
            when alu_count_leading_ones =>
            when alu_count_leading_zeros =>
            when alu_extend_byte =>
                intermediate_out(byte_msb downto 0) <= operand_B(byte_msb downto 0);
                intermediate_out(data_width downto byte_msb+1) <= (others => operand_B(byte_msb));
            when alu_extend_half =>
                intermediate_out(halfword_msb downto 0) <= operand_B(halfword_msb downto 0);
                intermediate_out(data_width-1 downto halfword_msb+1) <= (others => operand_B(halfword_msb));
            when others =>
                intermediate_out <= (others => '0');
                overflow_flag <= '0';
                zero_flag <= '0'; -- is not used
        end case ;
    end process ; -- computations

    computation_out <= intermediate_out(data_width-1 downto 0);

end behavioural ; -- behavioural

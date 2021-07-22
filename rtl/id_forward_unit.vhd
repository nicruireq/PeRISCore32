-------------------------------------------------------
--! @file   id_forward_unit.vhd
--! @brief ID forwarding unit
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library periscore32;
use periscore32.cpu_types.all;

entity id_forward_unit is
    port (
        ex_mem_reg_write : in control_signal;
        ex_mem_is_IType : in control_signal;
        ex_mem_rd : in register_index;
        ex_mem_rt : in register_index;
        mem_wb_reg_write : in control_signal;
        mem_wb_mem_read : in control_signal;
        mem_wb_is_IType : in control_signal;
        mem_wb_rd : in register_index;
        mem_wb_rt : in register_index;
        if_id_rs : in register_index;
        if_id_rt : in register_index;
        forward_A : out id_forward;
        forward_B : out id_forward
    );
end entity id_forward_unit;

architecture behavioral of id_forward_unit is
    -- Destination register in EX/MEM register
    signal ex_mem_dst : register_index;
    -- Destination register in MEM/WB register
    signal mem_wb_dst : register_index;
begin

    -- Selects destination register between rd or rt
    -- rd when R-Type and rt when I-Type
    ex_mem_dst <= ex_mem_rt when ex_mem_is_IType = '1'
                    else ex_mem_rd;
    
    mem_wb_dst <= mem_wb_rt when mem_wb_is_IType = '1'
                    else mem_wb_rd;
    
    forward_operand_A: process(ex_mem_reg_write, ex_mem_dst,
        mem_wb_dst, if_id_rs, mem_wb_reg_write, mem_wb_mem_read)
    begin
        -- First resolve R type in EX/MEM
        if (ex_mem_reg_write = '1') and
            (ex_mem_dst /= zero) and
            (ex_mem_dst = if_id_rs)
        then
            forward_A <= "01";
        -- Second, resolve LW in MEM/WB.
        -- Always have priority over R type
        -- because control signals for R-Type are
        -- a subset of those of LW. If not, LWs are
        -- never detected
        elsif (mem_wb_mem_read = '1') and
                (mem_wb_dst /= zero) and
                (mem_wb_dst = if_id_rs)
        then
            forward_A <= "10";
        -- Resolve R type in MEM/WB at the end
        elsif (mem_wb_reg_write = '1') and
                (mem_wb_dst /= zero) and
                (mem_wb_dst = if_id_rs)
        then
            forward_A <= "11";
        else
            forward_A <= "00";
        end if;
    end process forward_operand_A;

    forward_operand_B: process(ex_mem_reg_write, ex_mem_dst,
        mem_wb_dst, if_id_rt, mem_wb_reg_write, mem_wb_mem_read)
    begin
        if (ex_mem_reg_write = '1') and
            (ex_mem_dst /= zero) and
            (ex_mem_dst = if_id_rt)
        then
            forward_B <= "01";
        elsif (mem_wb_mem_read = '1') and
                (mem_wb_dst /= zero) and
                (mem_wb_dst = if_id_rt)
        then
            forward_B <= "10";
        elsif (mem_wb_reg_write = '1') and
                (mem_wb_dst /= zero) and
                (mem_wb_dst = if_id_rt)
        then
            forward_B <= "11";
        else
            forward_B <= "00";
        end if;
    end process forward_operand_B;
    
end architecture behavioral;
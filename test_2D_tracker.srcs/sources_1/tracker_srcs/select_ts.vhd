-------------------------------------------------------------------------------
-- Title      : Select TS
-- Project    : 
-------------------------------------------------------------------------------
-- File       : select_ts.vhd
-- Author     :   <ta@TZUAN-PC>
-- Company    : 
-- Created    : 2016-10-24
-- Last update: 2016-12-12
-- Platform   :
-----------------------------------------------------------------------------
-- Description: Select related TS of a peak
-- latency: 2 clock
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-10-24  1.0      ta	Created
-- 2016-11-03  1.1      ta	Two-step assignment
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.types.all;

entity select_ts is
    generic (
        NumTSF : natural := 80;
        base   : natural := 14);        -- test
    port(
        Top_clkData_s : in  std_logic                          := '1';
        track_hit     : in  std_logic_vector (NumTSF downto 0) := (others => '0');
        input_info    : in  SL_InputPst(0 to NumTSF)           := (others => (others => '0'));
        best_TS       : out std_logic_vector (20 downto 0)     := (others => '0')
        );
end select_ts;

architecture Behavioral of select_ts is
    constant Null_TSInfo   : std_logic_vector(20 downto 0) := (others => '0');
    subtype Index is natural range 0 to NumTSF + 1;
    signal SendIndex       : Index      := NumTSF + 1;
    type IndexArray is array (0 to NumTSF/base) of Index;
    signal FirstIndex      : IndexArray := (others => NumTSF + 1);
    signal SecondIndex     : IndexArray := (others => NumTSF + 1);
    signal priority_second : std_logic_vector (NumTSF downto 0);
    signal priority_first  : std_logic_vector (NumTSF downto 0);
    signal masked_info     : SL_InputPst(0 to NumTSF + 1)  := (others => (others => '0'));
    signal masked_info_r   : SL_InputPst(0 to NumTSF + 1)  := (others => (others => '0'));

    attribute max_fanout : integer;
    attribute equivalent_register_removal : string;
    attribute max_fanout of SendIndex : signal is 25;
    attribute equivalent_register_removal of SendIndex : signal is "no";

    -- purpose: Assign SendIndex according to hit and priority info
    procedure AssignBiggestIndex (
        constant q : in natural;
        constant r  : in natural;
        signal hit : in std_logic_vector;
        signal priority  : in std_logic_vector;
        signal OutIndex : out IndexArray) is
    begin  -- function AssignBiggestIndex
        OutIndex(q) <= NumTSF + 1;
        for i in base * q to base * q + r loop
            if (hit(i) = '1') and priority(i) = '1' then
                OutIndex(q) <= i;
            end if;
        end loop;
    end procedure AssignBiggestIndex;
begin
    SecondPriority : for i in 0 to NumTSF generate
        priority_second(i) <= input_info(i)(1) xor input_info(i)(0);
    end generate;
    FirstPriority : for i in 0 to NumTSF generate
        priority_first(i) <= input_info(i)(1) and input_info(i)(0);
    end generate;

    process(Top_clkData_s)
        constant lastbase : natural := base * (NumTSF/base);
    begin
        if rising_edge(Top_clkData_s) then
            SendIndex <= NumTSF + 1;
            for q in 0 to NumTSF/base - 1 loop
                AssignBiggestIndex(q, base - 1, track_hit, priority_second, SecondIndex);
                AssignBiggestIndex(q, base - 1, track_hit, priority_first, FirstIndex);
            end loop;
            AssignBiggestIndex(NumTSF/base, NumTSF - lastbase,
                               track_hit,
                               priority_second,
                               SecondIndex);
            AssignBiggestIndex(NumTSF/base, NumTSF - lastbase,
                               track_hit,
                               priority_first,
                               FirstIndex);
            for i in 0 to NumTSF/base loop
                if SecondIndex(i) /= NumTSF + 1 then
                    SendIndex <= SecondIndex(i);
                end if;
            end loop;
            for i in 0 to NumTSF/base loop
                if FirstIndex(i) /= NumTSF + 1 then
                    SendIndex <= FirstIndex(i);
                end if;
            end loop;
            masked_info_r <= input_info & Null_TSInfo;
            masked_info <= masked_info_r;
        end if;
    end process;
    best_TS <= masked_info(SendIndex);
end Behavioral;

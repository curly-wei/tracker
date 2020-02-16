-------------------------------------------------------------------------------
-- Title      : Select High pt
-- Project    : 
-------------------------------------------------------------------------------
-- File       : select_highpt.vhd
-- Author     : Tzu-An Sheng  <tasheng@hep1.phys.ntu.edu.tw>
-- Company    : 
-- Created    : 2016-10-20
-- Last update: 2016-11-03
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: choose highest pt cell on Group Map
-- In addition, favor small phi.
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-10-20  1.0      tristesse	Created
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.types.all;
entity select_highpt is

    port (
        track_map     : out GroupMap := (others => (others => '0'));
        group_map     : in  GroupMap;
        Top_clkData_s : in  std_logic);

end entity select_highpt;

architecture arc of select_highpt is

    constant ymid : natural    := SquareMapHeight/2;
    signal OneHot : GroupMap := (others => (others => '0'));
begin  -- architecture arc

    process (Top_clkData_s)
        variable found  : std_logic := '0';
    begin
        if rising_edge(Top_clkData_s) then
            found := '0';
            OneHot <= (others => (others => '0'));
            for dy in 0 to ymid loop
                for x in GroupMapRow'range loop
                    if group_map(ymid + dy)(x) = '1' and found = '0' then
                        OneHot(ymid + dy)(x) <= '1';
                        found := '1';
                    elsif group_map(ymid - dy)(x) = '1' and found = '0' then
                        OneHot(ymid - dy)(x) <= '1';
                        found := '1';
                    end if;
                end loop;
            end loop;
        end if;
    end process;

    track_map <= OneHot;

end architecture arc;

-------------------------------------------------------------------------------
-- Title      : Testbench for design "persistor"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : persistor_tb.vhd
-- Author     : Tzu-An Sheng  <tasheng@hep1.phys.ntu.edu.tw>
-- Company    : 
-- Created    : 2016-04-08
-- Last update: 2018-02-07
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-04-08  1.0      tristesse	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- use IEEE.std_logic_unsigned.all;
-- use IEEE.STD_LOGIC_ARITH.all;
use STD.TEXTIO.all;

-------------------------------------------------------------------------------

entity persistor_tb is

end entity persistor_tb;

-------------------------------------------------------------------------------

architecture sanity of persistor_tb is

    ---- component ports
    signal TSF0_input_i  : std_logic_vector (428 downto 0) := (others => '1');
    signal TSF2_input_i  : std_logic_vector (428 downto 0) := (others => '1');
    signal TSF4_input_i  : std_logic_vector (428 downto 0) := (others => '1');
    signal TSF6_input_i  : std_logic_vector (428 downto 0) := (others => '1');
    signal TSF8_input_i  : std_logic_vector (428 downto 0) := (others => '1');
    signal Main_out      : std_logic_vector (731 downto 0) := (others => '0');
    signal Top_clkData_s : std_logic                       := '1';

     --clock
    signal Top_Cbdummy32_s  : std_logic_vector(31 downto 0) := (others => '0');
    signal Clk : std_logic := '1';

begin  -- architecture sanity

    Top_clkData_s <= Clk;
    -- component instantiation
    DUT: entity work.persistor
        port map (
            TSF0_input_i  => TSF0_input_i(428 downto 210),
            TSF2_input_i  => TSF2_input_i(428 downto 210),
            TSF4_input_i  => TSF4_input_i(428 downto 210),
            TSF6_input_i  => TSF6_input_i(428 downto 210),
            TSF8_input_i  => TSF8_input_i(428 downto 210),
            Main_out      => Main_out,
            Top_clkData_s => Top_clkData_s);

    gen: entity work.feed
        port map (
            TSF0_input => TSF0_input_i,
            TSF2_input => TSF2_input_i,
            TSF4_input => TSF4_input_i,
            TSF6_input => TSF6_input_i,
            TSF8_input => TSF8_input_i,
            Top_clkData_s => Top_clkData_s);
    -- clock generation
    Clk <= not Clk after 10 ns;

    -- waveform generation
    WaveGen_Proc: process
    begin
        -- insert signal assignments here

        wait until Clk = '1';
    end process WaveGen_Proc;

    --Top_Cbdummy32_sReset : process(Top_clkData_s)
    --begin
    --    if (Top_clkData_s'event and Top_clkData_s = '1') then
    --        Top_Cbdummy32_s <= Top_Cbdummy32_s + '1';
    --    if ((Top_Cbdummy32_s(4 downto 0) = "00000")) then
    --        for i in 0 to 19 loop
    --            TSF0_input_i(21*i + 12 downto 21*i) <= "1010101010101";
    --        end loop;
    --        TSF0_input_i(20 downto 13) <= "00011100";
    --        TSF0_input_i(41 downto 34) <= "00001011";
    --        TSF0_input_i(62 downto 55) <= "00101101";
    --        TSF0_input_i(83 downto 76) <= "00010100";
    --        TSF0_input_i(104 downto 97) <= "00100000";
    --        TSF0_input_i(125 downto 118) <= "00010101";
    --        TSF0_input_i(146 downto 139) <= "00110001";
    --        TSF0_input_i(167 downto 160) <= "00110000";
    --        TSF0_input_i(188 downto 181) <= "00010011";
    --        TSF0_input_i(209 downto 202) <= "00101101";
    --        TSF0_input_i(230 downto 223) <= "00010100";
    --        TSF0_input_i(251 downto 244) <= "00000100";
    --        TSF0_input_i(272 downto 265) <= "00010111";
    --        TSF0_input_i(293 downto 286) <= "00100101";
    --        TSF0_input_i(314 downto 307) <= "00000010";
    --        TSF0_input_i(335 downto 328) <= "00011001";
    --        TSF0_input_i(356 downto 349) <= "00001010";
    --        TSF0_input_i(377 downto 370) <= "01001000";
    --        TSF0_input_i(398 downto 391) <= "00111001";
    --        TSF0_input_i(419 downto 412) <= "00000110";
    --    elsif ((Top_Cbdummy32_s(4 downto 0) = "00010")) then
    --        for i in 0 to 19 loop
    --            TSF2_input_i(21*i + 12 downto 21*i) <= "1010101010101";
    --        end loop;
    --        TSF2_input_i(20 downto 13) <= "00100100";
    --        TSF2_input_i(41 downto 34) <= "00001110";
    --        TSF2_input_i(62 downto 55) <= "00111000";
    --        TSF2_input_i(83 downto 76) <= "00011011";
    --        TSF2_input_i(104 downto 97) <= "00101010";
    --        TSF2_input_i(125 downto 118) <= "00011101";
    --        TSF2_input_i(146 downto 139) <= "00111101";
    --        TSF2_input_i(167 downto 160) <= "00111011";
    --        TSF2_input_i(188 downto 181) <= "00011001";
    --        TSF2_input_i(209 downto 202) <= "00111001";
    --        TSF2_input_i(230 downto 223) <= "00011010";
    --        TSF2_input_i(251 downto 244) <= "00000111";
    --        TSF2_input_i(272 downto 265) <= "00011101";
    --        TSF2_input_i(293 downto 286) <= "00110000";
    --        TSF2_input_i(314 downto 307) <= "00000100";
    --        TSF2_input_i(335 downto 328) <= "00100001";
    --        TSF2_input_i(356 downto 349) <= "00001100";
    --        TSF2_input_i(377 downto 370) <= "01011000";
    --        TSF2_input_i(398 downto 391) <= "01000101";
    --        TSF2_input_i(419 downto 412) <= "00001001";
    --    elsif ((Top_Cbdummy32_s(4 downto 0) = "00100")) then
    --        for i in 0 to 19 loop
    --            TSF4_input_i(21*i + 12 downto 21*i) <= "1010101010101";
    --        end loop;
    --        TSF4_input_i(20 downto 13) <= "00110011";
    --        TSF4_input_i(41 downto 34) <= "00010101";
    --        TSF4_input_i(62 downto 55) <= "01001100";
    --        TSF4_input_i(83 downto 76) <= "00101000";
    --        TSF4_input_i(104 downto 97) <= "00111100";
    --        TSF4_input_i(125 downto 118) <= "00101010";
    --        TSF4_input_i(146 downto 139) <= "01010011";
    --        TSF4_input_i(167 downto 160) <= "01010000";
    --        TSF4_input_i(188 downto 181) <= "00100100";
    --        TSF4_input_i(209 downto 202) <= "01010000";
    --        TSF4_input_i(230 downto 223) <= "00100100";
    --        TSF4_input_i(251 downto 244) <= "00001100";
    --        TSF4_input_i(272 downto 265) <= "00100111";
    --        TSF4_input_i(293 downto 286) <= "01000100";
    --        TSF4_input_i(314 downto 307) <= "00000110";
    --        TSF4_input_i(335 downto 328) <= "00110000";
    --        TSF4_input_i(356 downto 349) <= "00010000";
    --        TSF4_input_i(377 downto 370) <= "01111000";
    --        TSF4_input_i(398 downto 391) <= "01011101";
    --        TSF4_input_i(419 downto 412) <= "00001110";
    --    elsif ((Top_Cbdummy32_s(4 downto 0) = "00110")) then
    --        for i in 0 to 19 loop
    --            TSF6_input_i(21*i + 12 downto 21*i) <= "1010101010101";
    --        end loop;
    --        TSF6_input_i(20 downto 13) <= "01000100";
    --        TSF6_input_i(41 downto 34) <= "00011100";
    --        TSF6_input_i(62 downto 55) <= "01100010";
    --        TSF6_input_i(83 downto 76) <= "00110111";
    --        TSF6_input_i(104 downto 97) <= "01010001";
    --        TSF6_input_i(125 downto 118) <= "00111010";
    --        TSF6_input_i(146 downto 139) <= "01101011";
    --        TSF6_input_i(167 downto 160) <= "01100111";
    --        TSF6_input_i(188 downto 181) <= "00110000";
    --        TSF6_input_i(209 downto 202) <= "01101001";
    --        TSF6_input_i(230 downto 223) <= "00101111";
    --        TSF6_input_i(251 downto 244) <= "00010011";
    --        TSF6_input_i(272 downto 265) <= "00110011";
    --        TSF6_input_i(293 downto 286) <= "01011011";
    --        TSF6_input_i(314 downto 307) <= "00001001";
    --        TSF6_input_i(335 downto 328) <= "01000010";
    --        TSF6_input_i(356 downto 349) <= "00010100";
    --        TSF6_input_i(377 downto 370) <= "10011000";
    --        TSF6_input_i(398 downto 391) <= "01110111";
    --        TSF6_input_i(419 downto 412) <= "00010011";
    --    elsif ((Top_Cbdummy32_s(4 downto 0) = "01000")) then
    --        for i in 0 to 19 loop
    --            TSF8_input_i(21*i + 12 downto 21*i) <= "1010101010101";
    --        end loop;
    --        TSF8_input_i(20 downto 13)   <= "01010110";
    --        TSF8_input_i(41 downto 34)   <= "00100100";
    --        TSF8_input_i(62 downto 55)   <= "01111000";
    --        TSF8_input_i(83 downto 76)   <= "01001000";
    --        TSF8_input_i(104 downto 97)  <= "01101001";
    --        TSF8_input_i(125 downto 118) <= "01001100";
    --        TSF8_input_i(146 downto 139) <= "10000100";
    --        TSF8_input_i(167 downto 160) <= "01111111";
    --        TSF8_input_i(188 downto 181) <= "00111101";
    --        TSF8_input_i(209 downto 202) <= "10000110";
    --        TSF8_input_i(230 downto 223) <= "00111011";
    --        TSF8_input_i(251 downto 244) <= "00011100";
    --        TSF8_input_i(272 downto 265) <= "00111111";
    --        TSF8_input_i(293 downto 286) <= "01110100";
    --        TSF8_input_i(314 downto 307) <= "00001100";
    --        TSF8_input_i(335 downto 328) <= "01010101";
    --        TSF8_input_i(356 downto 349) <= "00011001";
    --        TSF8_input_i(377 downto 370) <= "10111010";
    --        TSF8_input_i(398 downto 391) <= "10010001";
    --        TSF8_input_i(419 downto 412) <= "00011010";

    --        else
    --            TSF0_input_i           <= (others => '1');
    --            TSF2_input_i           <= (others => '1');
    --            TSF4_input_i           <= (others => '1');
    --            TSF6_input_i           <= (others => '1');
    --            TSF8_input_i           <= (others => '1');

    --        end if;
    --    end if;
    --end process;
    

end architecture sanity;

-------------------------------------------------------------------------------

configuration persistor_tb_sanity_cfg of persistor_tb is
    for sanity
    end for;
end persistor_tb_sanity_cfg;

-------------------------------------------------------------------------------

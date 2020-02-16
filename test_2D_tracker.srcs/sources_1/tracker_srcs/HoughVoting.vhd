----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    22:26:02 07/04/2014
-- Design Name:
-- Module Name:    UT3_0_HoughVoting_M - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.types.all;

entity HoughVoting is

Port (
      HoughMap : out SL_Map_ex(ConstHoughMap'range);
      SL0_TS   : IN  SL_Hit(NumTSF0 downto 0);
      SL2_TS   : IN  SL_Hit(NumTSF2 downto 0);
      SL4_TS   : IN  SL_Hit(NumTSF4 downto 0);
      SL6_TS   : IN  SL_Hit(NumTSF6 downto 0);
      SL8_TS   : IN  SL_Hit(NumTSF8 downto 0);
			Top_clkData_s : IN  std_logic
		);

end HoughVoting;

architecture Behavioral of HoughVoting is

    signal SL0_map : SL_Map_ex(ConstHoughMap'range);
    signal SL2_map : SL_Map_ex(ConstHoughMap'range);
    signal SL4_map : SL_Map_ex(ConstHoughMap'range);
    signal SL6_map : SL_Map_ex(ConstHoughMap'range);
    signal SL8_map : SL_Map_ex(ConstHoughMap'range);


 COMPONENT Mapping_SL0
    PORT(
        SL0_map : OUT SL_Map_ex(ConstHoughMap'range);
        SL0_TS  : IN  SL_Hit(NumTSF0 downto 0));
    END COMPONENT;

	 COMPONENT Mapping_SL2
    PORT(
        SL2_map : OUT SL_Map_ex(ConstHoughMap'range);
        SL2_TS  : IN  SL_Hit(NumTSF2 downto 0));
    END COMPONENT;

	 COMPONENT Mapping_SL4
    PORT(
        SL4_map : OUT SL_Map_ex(ConstHoughMap'range);
        SL4_TS  : IN  SL_Hit(NumTSF4 downto 0));
    END COMPONENT;

	 COMPONENT Mapping_SL6
    PORT(
        SL6_map : OUT SL_Map_ex(ConstHoughMap'range);
        SL6_TS  : IN  SL_Hit(NumTSF6 downto 0));
    END COMPONENT;

	 COMPONENT Mapping_SL8
    PORT(
        SL8_map : OUT SL_Map_ex(ConstHoughMap'range);
        SL8_TS  : IN  SL_Hit(NumTSF8 downto 0));
    END COMPONENT;


begin

    Mapping_0: Mapping_SL0
        PORT map(
            SL0_map => SL0_map,
            SL0_TS  => SL0_TS
            );

    Mapping_2: Mapping_SL2
        PORT map(
            SL2_map => SL2_map,
            SL2_TS  => SL2_TS
            );

    Mapping_4: Mapping_SL4
        PORT map(
            SL4_map => SL4_map,
            SL4_TS  => SL4_TS
            );

    Mapping_6: Mapping_SL6
        PORT map(
            SL6_map => SL6_map,
            SL6_TS  => SL6_TS
            );

    Mapping_8: Mapping_SL8
        PORT map(
            SL8_map => SL8_map,
            SL8_TS  => SL8_TS
            );

    geny: for y in 0 to nY - 1 generate
        genx: for x in 0 to X2 generate
            HoughMap(y)(x) <= (SL0_map(y)(x) and SL2_map(y)(x) and SL4_map(y)(x) and SL6_map(y)(x)) or
                              (SL0_map(y)(x) and SL2_map(y)(x) and SL4_map(y)(x) and SL8_map(y)(x)) or
                              (SL0_map(y)(x) and SL2_map(y)(x) and SL6_map(y)(x) and SL8_map(y)(x)) or
                              (SL0_map(y)(x) and SL4_map(y)(x) and SL6_map(y)(x) and SL8_map(y)(x)) or
                              (SL2_map(y)(x) and SL4_map(y)(x) and SL6_map(y)(x) and SL8_map(y)(x));
        end generate genx;
    end generate geny;

end Behavioral;

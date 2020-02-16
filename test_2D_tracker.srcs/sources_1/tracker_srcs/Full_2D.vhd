----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    11:26:42 11/09/2015
-- Design Name:
-- Module Name:    Full_2D - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use work.types.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Full_2D is
    port (
        SL0_best_TS_track1_M : out std_logic_vector (20 downto 0);
        SL2_best_TS_track1_M : out std_logic_vector (20 downto 0);
        SL4_best_TS_track1_M : out std_logic_vector (20 downto 0);
        SL6_best_TS_track1_M : out std_logic_vector (20 downto 0);
        SL8_best_TS_track1_M : out std_logic_vector (20 downto 0);

        SL0_best_TS_track2_M : out std_logic_vector (20 downto 0);
        SL2_best_TS_track2_M : out std_logic_vector (20 downto 0);
        SL4_best_TS_track2_M : out std_logic_vector (20 downto 0);
        SL6_best_TS_track2_M : out std_logic_vector (20 downto 0);
        SL8_best_TS_track2_M : out std_logic_vector (20 downto 0);

        SL0_best_TS_track3_M : out std_logic_vector (20 downto 0);
        SL2_best_TS_track3_M : out std_logic_vector (20 downto 0);
        SL4_best_TS_track3_M : out std_logic_vector (20 downto 0);
        SL6_best_TS_track3_M : out std_logic_vector (20 downto 0);
        SL8_best_TS_track3_M : out std_logic_vector (20 downto 0);

        SL0_best_TS_track1_P : out std_logic_vector (20 downto 0);
        SL2_best_TS_track1_P : out std_logic_vector (20 downto 0);
        SL4_best_TS_track1_P : out std_logic_vector (20 downto 0);
        SL6_best_TS_track1_P : out std_logic_vector (20 downto 0);
        SL8_best_TS_track1_P : out std_logic_vector (20 downto 0);

        SL0_best_TS_track2_P : out std_logic_vector (20 downto 0);
        SL2_best_TS_track2_P : out std_logic_vector (20 downto 0);
        SL4_best_TS_track2_P : out std_logic_vector (20 downto 0);
        SL6_best_TS_track2_P : out std_logic_vector (20 downto 0);
        SL8_best_TS_track2_P : out std_logic_vector (20 downto 0);

        SL0_best_TS_track3_P : out std_logic_vector (20 downto 0);
        SL2_best_TS_track3_P : out std_logic_vector (20 downto 0);
        SL4_best_TS_track3_P : out std_logic_vector (20 downto 0);
        SL6_best_TS_track3_P : out std_logic_vector (20 downto 0);
        SL8_best_TS_track3_P : out std_logic_vector (20 downto 0);

        HoughCell_track1_M : out std_logic_vector (9 downto 0);
        HoughCell_track2_M : out std_logic_vector (9 downto 0);
        HoughCell_track3_M : out std_logic_vector (9 downto 0);
        HoughCell_track1_P : out std_logic_vector (9 downto 0);
        HoughCell_track2_P : out std_logic_vector (9 downto 0);
        HoughCell_track3_P : out std_logic_vector (9 downto 0);
        track1M_found : out std_logic := '0';
        track2M_found : out std_logic := '0';
        track3M_found : out std_logic := '0';
        track1P_found : out std_logic := '0';
        track2P_found : out std_logic := '0';
        track3P_found : out std_logic := '0';

        TSF0_input : in SL_InputPst(0 to 80);
        TSF2_input : in SL_InputPst(0 to 96);
        TSF4_input : in SL_InputPst(0 to 128);
        TSF6_input : in SL_InputPst(0 to 160);
        TSF8_input : in SL_InputPst(0 to 192);

        SL0_TS        : in std_logic_vector(80 downto 0);
        SL2_TS        : in std_logic_vector(96 downto 0);
        SL4_TS        : in std_logic_vector(128 downto 0);
        SL6_TS        : in std_logic_vector(160 downto 0);
        SL8_TS        : in std_logic_vector(192 downto 0);
        Top_clkData_s : in std_logic
        );

end Full_2D;

architecture Behavioral of Full_2D is

    signal Minus_row1  : std_logic_vector (79 downto 40);
    signal Minus_row2  : std_logic_vector (79 downto 40);
    signal Minus_row3  : std_logic_vector (79 downto 40);
    signal Minus_row4  : std_logic_vector (79 downto 40);
    signal Minus_row5  : std_logic_vector (79 downto 40);
    signal Minus_row6  : std_logic_vector (79 downto 40);
    signal Minus_row7  : std_logic_vector (79 downto 40);
    signal Minus_row8  : std_logic_vector (79 downto 40);
    signal Minus_row9  : std_logic_vector (79 downto 40);
    signal Minus_row10 : std_logic_vector (79 downto 40);
    signal Minus_row11 : std_logic_vector (79 downto 40);
    signal Minus_row12 : std_logic_vector (79 downto 40);
    signal Minus_row13 : std_logic_vector (79 downto 40);
    signal Minus_row14 : std_logic_vector (79 downto 40);
    signal Minus_row15 : std_logic_vector (79 downto 40);
    signal Minus_row16 : std_logic_vector (79 downto 40);

    signal Plus_row1  : std_logic_vector (39 downto 0);
    signal Plus_row2  : std_logic_vector (39 downto 0);
    signal Plus_row3  : std_logic_vector (39 downto 0);
    signal Plus_row4  : std_logic_vector (39 downto 0);
    signal Plus_row5  : std_logic_vector (39 downto 0);
    signal Plus_row6  : std_logic_vector (39 downto 0);
    signal Plus_row7  : std_logic_vector (39 downto 0);
    signal Plus_row8  : std_logic_vector (39 downto 0);
    signal Plus_row9  : std_logic_vector (39 downto 0);
    signal Plus_row10 : std_logic_vector (39 downto 0);
    signal Plus_row11 : std_logic_vector (39 downto 0);
    signal Plus_row12 : std_logic_vector (39 downto 0);
    signal Plus_row13 : std_logic_vector (39 downto 0);
    signal Plus_row14 : std_logic_vector (39 downto 0);
    signal Plus_row15 : std_logic_vector (39 downto 0);
    signal Plus_row16 : std_logic_vector (39 downto 0);

    --2D Finder
    component UT3_0_Cluster_M
        port (
            Minus_row1    : out std_logic_vector (79 downto 40);
            Minus_row2    : out std_logic_vector (79 downto 40);
            Minus_row3    : out std_logic_vector (79 downto 40);
            Minus_row4    : out std_logic_vector (79 downto 40);
            Minus_row5    : out std_logic_vector (79 downto 40);
            Minus_row6    : out std_logic_vector (79 downto 40);
            Minus_row7    : out std_logic_vector (79 downto 40);
            Minus_row8    : out std_logic_vector (79 downto 40);
            Minus_row9    : out std_logic_vector (79 downto 40);
            Minus_row10   : out std_logic_vector (79 downto 40);
            Minus_row11   : out std_logic_vector (79 downto 40);
            Minus_row12   : out std_logic_vector (79 downto 40);
            Minus_row13   : out std_logic_vector (79 downto 40);
            Minus_row14   : out std_logic_vector (79 downto 40);
            Minus_row15   : out std_logic_vector (79 downto 40);
            Minus_row16   : out std_logic_vector (79 downto 40);
            SL0_TS        : in  std_logic_vector(80 downto 0);
            SL2_TS        : in  std_logic_vector(96 downto 0);
            SL4_TS        : in  std_logic_vector(128 downto 0);
            SL6_TS        : in  std_logic_vector(160 downto 0);
            SL8_TS        : in  std_logic_vector(192 downto 0);
            Top_clkData_s : in  std_logic
            );
    end component;

    component UT3_0_Cluster_P
        port (
            Plus_row1     : out std_logic_vector (39 downto 0);
            Plus_row2     : out std_logic_vector (39 downto 0);
            Plus_row3     : out std_logic_vector (39 downto 0);
            Plus_row4     : out std_logic_vector (39 downto 0);
            Plus_row5     : out std_logic_vector (39 downto 0);
            Plus_row6     : out std_logic_vector (39 downto 0);
            Plus_row7     : out std_logic_vector (39 downto 0);
            Plus_row8     : out std_logic_vector (39 downto 0);
            Plus_row9     : out std_logic_vector (39 downto 0);
            Plus_row10    : out std_logic_vector (39 downto 0);
            Plus_row11    : out std_logic_vector (39 downto 0);
            Plus_row12    : out std_logic_vector (39 downto 0);
            Plus_row13    : out std_logic_vector (39 downto 0);
            Plus_row14    : out std_logic_vector (39 downto 0);
            Plus_row15    : out std_logic_vector (39 downto 0);
            Plus_row16    : out std_logic_vector (39 downto 00);
            SL0_TS        : in  std_logic_vector(80 downto 0);
            SL2_TS        : in  std_logic_vector(96 downto 0);
            SL4_TS        : in  std_logic_vector(128 downto 0);
            SL6_TS        : in  std_logic_vector(160 downto 0);
            SL8_TS        : in  std_logic_vector(192 downto 0);
            Top_clkData_s : in  std_logic
            );
    end component;

    component select2D is
        port(
            select_row1  : in std_logic_vector (79 downto 40);
            select_row2  : in std_logic_vector (79 downto 40);
            select_row3  : in std_logic_vector (79 downto 40);
            select_row4  : in std_logic_vector (79 downto 40);
            select_row5  : in std_logic_vector (79 downto 40);
            select_row6  : in std_logic_vector (79 downto 40);
            select_row7  : in std_logic_vector (79 downto 40);
            select_row8  : in std_logic_vector (79 downto 40);
            select_row9  : in std_logic_vector (79 downto 40);
            select_row10 : in std_logic_vector (79 downto 40);
            select_row11 : in std_logic_vector (79 downto 40);
            select_row12 : in std_logic_vector (79 downto 40);
            select_row13 : in std_logic_vector (79 downto 40);
            select_row14 : in std_logic_vector (79 downto 40);
            select_row15 : in std_logic_vector (79 downto 40);
            select_row16 : in std_logic_vector (79 downto 40);

            TSF0_input : in SL_InputPst(0 to 80);
            TSF2_input : in SL_InputPst(0 to 96);
            TSF4_input : in SL_InputPst(0 to 128);
            TSF6_input : in SL_InputPst(0 to 160);
            TSF8_input : in SL_InputPst(0 to 192);

            SL0_TS     : in std_logic_vector (NumTSF0 downto 0);
            SL2_TS     : in std_logic_vector (NumTSF2 downto 0);
            SL4_TS     : in std_logic_vector (NumTSF4 downto 0);
            SL6_TS     : in std_logic_vector (NumTSF6 downto 0);
            SL8_TS     : in std_logic_vector (NumTSF8 downto 0);

            SL0_best_TS_track1 : out std_logic_vector (20 downto 0);
            SL2_best_TS_track1 : out std_logic_vector (20 downto 0);
            SL4_best_TS_track1 : out std_logic_vector (20 downto 0);
            SL6_best_TS_track1 : out std_logic_vector (20 downto 0);
            SL8_best_TS_track1 : out std_logic_vector (20 downto 0);

            SL0_best_TS_track2 : out std_logic_vector (20 downto 0);
            SL2_best_TS_track2 : out std_logic_vector (20 downto 0);
            SL4_best_TS_track2 : out std_logic_vector (20 downto 0);
            SL6_best_TS_track2 : out std_logic_vector (20 downto 0);
            SL8_best_TS_track2 : out std_logic_vector (20 downto 0);

            SL0_best_TS_track3 : out std_logic_vector (20 downto 0);
            SL2_best_TS_track3 : out std_logic_vector (20 downto 0);
            SL4_best_TS_track3 : out std_logic_vector (20 downto 0);
            SL6_best_TS_track3 : out std_logic_vector (20 downto 0);
            SL8_best_TS_track3 : out std_logic_vector (20 downto 0);

            HoughCell_track1 : out std_logic_vector (9 downto 0);
            HoughCell_track2 : out std_logic_vector (9 downto 0);
            HoughCell_track3 : out std_logic_vector (9 downto 0);
            track1_found : out std_logic := '0';
            track2_found : out std_logic := '0';
            track3_found : out std_logic := '0';
            Top_clkData_s : in std_logic
            );
    end component;


    component select2D_P is
        port(
            select_row1  : in std_logic_vector (39 downto 0);
            select_row2  : in std_logic_vector (39 downto 0);
            select_row3  : in std_logic_vector (39 downto 0);
            select_row4  : in std_logic_vector (39 downto 0);
            select_row5  : in std_logic_vector (39 downto 0);
            select_row6  : in std_logic_vector (39 downto 0);
            select_row7  : in std_logic_vector (39 downto 0);
            select_row8  : in std_logic_vector (39 downto 0);
            select_row9  : in std_logic_vector (39 downto 0);
            select_row10 : in std_logic_vector (39 downto 0);
            select_row11 : in std_logic_vector (39 downto 0);
            select_row12 : in std_logic_vector (39 downto 0);
            select_row13 : in std_logic_vector (39 downto 0);
            select_row14 : in std_logic_vector (39 downto 0);
            select_row15 : in std_logic_vector (39 downto 0);
            select_row16 : in std_logic_vector (39 downto 0);

            TSF0_input : in SL_InputPst(0 to 80);
            TSF2_input : in SL_InputPst(0 to 96);
            TSF4_input : in SL_InputPst(0 to 128);
            TSF6_input : in SL_InputPst(0 to 160);
            TSF8_input : in SL_InputPst(0 to 192);

            SL0_TS     : in std_logic_vector (NumTSF0 downto 0);
            SL2_TS     : in std_logic_vector (NumTSF2 downto 0);
            SL4_TS     : in std_logic_vector (NumTSF4 downto 0);
            SL6_TS     : in std_logic_vector (NumTSF6 downto 0);
            SL8_TS     : in std_logic_vector (NumTSF8 downto 0);

            SL0_best_TS_track1 : out std_logic_vector (20 downto 0);
            SL2_best_TS_track1 : out std_logic_vector (20 downto 0);
            SL4_best_TS_track1 : out std_logic_vector (20 downto 0);
            SL6_best_TS_track1 : out std_logic_vector (20 downto 0);
            SL8_best_TS_track1 : out std_logic_vector (20 downto 0);

            SL0_best_TS_track2 : out std_logic_vector (20 downto 0);
            SL2_best_TS_track2 : out std_logic_vector (20 downto 0);
            SL4_best_TS_track2 : out std_logic_vector (20 downto 0);
            SL6_best_TS_track2 : out std_logic_vector (20 downto 0);
            SL8_best_TS_track2 : out std_logic_vector (20 downto 0);

            SL0_best_TS_track3 : out std_logic_vector (20 downto 0);
            SL2_best_TS_track3 : out std_logic_vector (20 downto 0);
            SL4_best_TS_track3 : out std_logic_vector (20 downto 0);
            SL6_best_TS_track3 : out std_logic_vector (20 downto 0);
            SL8_best_TS_track3 : out std_logic_vector (20 downto 0);

            HoughCell_track1 : out std_logic_vector (9 downto 0);
            HoughCell_track2 : out std_logic_vector (9 downto 0);
            HoughCell_track3 : out std_logic_vector (9 downto 0);
            track1_found : out std_logic := '0';
            track2_found : out std_logic := '0';
            track3_found : out std_logic := '0';
            Top_clkData_s : in std_logic
            );
    end component;

begin

    clm : UT3_0_Cluster_M
        port map (
            Minus_row1(79 downto 40)  => Minus_row1(79 downto 40),
            Minus_row2(79 downto 40)  => Minus_row2(79 downto 40),
            Minus_row3(79 downto 40)  => Minus_row3(79 downto 40),
            Minus_row4(79 downto 40)  => Minus_row4(79 downto 40),
            Minus_row5(79 downto 40)  => Minus_row5(79 downto 40),
            Minus_row6(79 downto 40)  => Minus_row6(79 downto 40),
            Minus_row7(79 downto 40)  => Minus_row7(79 downto 40),
            Minus_row8(79 downto 40)  => Minus_row8(79 downto 40),
            Minus_row9(79 downto 40)  => Minus_row9(79 downto 40),
            Minus_row10(79 downto 40) => Minus_row10(79 downto 40),
            Minus_row11(79 downto 40) => Minus_row11(79 downto 40),
            Minus_row12(79 downto 40) => Minus_row12(79 downto 40),
            Minus_row13(79 downto 40) => Minus_row13(79 downto 40),
            Minus_row14(79 downto 40) => Minus_row14(79 downto 40),
            Minus_row15(79 downto 40) => Minus_row15(79 downto 40),
            Minus_row16(79 downto 40) => Minus_row16(79 downto 40),

            SL0_TS(80 downto 0)  => SL0_TS(80 downto 0),
            SL2_TS(96 downto 0)  => SL2_TS(96 downto 0),
            SL4_TS(128 downto 0) => SL4_TS(128 downto 0),
            SL6_TS(160 downto 0) => SL6_TS(160 downto 0),
            SL8_TS(192 downto 0) => SL8_TS(192 downto 0),

            Top_clkData_s => Top_clkData_s
            );

    clm1 : UT3_0_Cluster_P
        port map (
            Plus_row1(39 downto 0)  => Plus_row1(39 downto 0),
            Plus_row2(39 downto 0)  => Plus_row2(39 downto 0),
            Plus_row3(39 downto 0)  => Plus_row3(39 downto 0),
            Plus_row4(39 downto 0)  => Plus_row4(39 downto 0),
            Plus_row5(39 downto 0)  => Plus_row5(39 downto 0),
            Plus_row6(39 downto 0)  => Plus_row6(39 downto 0),
            Plus_row7(39 downto 0)  => Plus_row7(39 downto 0),
            Plus_row8(39 downto 0)  => Plus_row8(39 downto 0),
            Plus_row9(39 downto 0)  => Plus_row9(39 downto 0),
            Plus_row10(39 downto 0) => Plus_row10(39 downto 0),
            Plus_row11(39 downto 0) => Plus_row11(39 downto 0),
            Plus_row12(39 downto 0) => Plus_row12(39 downto 0),
            Plus_row13(39 downto 0) => Plus_row13(39 downto 0),
            Plus_row14(39 downto 0) => Plus_row14(39 downto 0),
            Plus_row15(39 downto 0) => Plus_row15(39 downto 0),
            Plus_row16(39 downto 0) => Plus_row16(39 downto 0),

            SL0_TS(80 downto 0)  => SL0_TS(80 downto 0),
            SL2_TS(96 downto 0)  => SL2_TS(96 downto 0),
            SL4_TS(128 downto 0) => SL4_TS(128 downto 0),
            SL6_TS(160 downto 0) => SL6_TS(160 downto 0),
            SL8_TS(192 downto 0) => SL8_TS(192 downto 0),
            Top_clkData_s        => Top_clkData_s
            );


    sl1 : select2D
        port map (
            select_row1  => Minus_row1,
            select_row2  => Minus_row2,
            select_row3  => Minus_row3,
            select_row4  => Minus_row4,
            select_row5  => Minus_row5,
            select_row6  => Minus_row6,
            select_row7  => Minus_row7,
            select_row8  => Minus_row8,
            select_row9  => Minus_row9,
            select_row10 => Minus_row10,
            select_row11 => Minus_row11,
            select_row12 => Minus_row12,
            select_row13 => Minus_row13,
            select_row14 => Minus_row14,
            select_row15 => Minus_row15,
            select_row16 => Minus_row16,

            TSF0_input => TSF0_input,
            TSF2_input => TSF2_input,
            TSF4_input => TSF4_input,
            TSF6_input => TSF6_input,
            TSF8_input => TSF8_input,

            SL0_TS => SL0_TS,
            SL2_TS => SL2_TS,
            SL4_TS => SL4_TS,
            SL6_TS => SL6_TS,
            SL8_TS => SL8_TS,

            SL0_best_TS_track1 => SL0_best_TS_track1_M,
            SL2_best_TS_track1 => SL2_best_TS_track1_M,
            SL4_best_TS_track1 => SL4_best_TS_track1_M,
            SL6_best_TS_track1 => SL6_best_TS_track1_M,
            SL8_best_TS_track1 => SL8_best_TS_track1_M,

            SL0_best_TS_track2 => SL0_best_TS_track2_M,
            SL2_best_TS_track2 => SL2_best_TS_track2_M,
            SL4_best_TS_track2 => SL4_best_TS_track2_M,
            SL6_best_TS_track2 => SL6_best_TS_track2_M,
            SL8_best_TS_track2 => SL8_best_TS_track2_M,

            SL0_best_TS_track3 => SL0_best_TS_track3_M,
            SL2_best_TS_track3 => SL2_best_TS_track3_M,
            SL4_best_TS_track3 => SL4_best_TS_track3_M,
            SL6_best_TS_track3 => SL6_best_TS_track3_M,
            SL8_best_TS_track3 => SL8_best_TS_track3_M,

            HoughCell_track1 => HoughCell_track1_M,
            HoughCell_track2 => HoughCell_track2_M,
            HoughCell_track3 => HoughCell_track3_M,
            track1_found => track1M_found,
            track2_found => track2M_found,
            track3_found => track3M_found,
            Top_clkData_s => Top_clkData_s
            );

    sl2 : select2D_P
        port map (
            select_row1  => Plus_row1,
            select_row2  => Plus_row2,
            select_row3  => Plus_row3,
            select_row4  => Plus_row4,
            select_row5  => Plus_row5,
            select_row6  => Plus_row6,
            select_row7  => Plus_row7,
            select_row8  => Plus_row8,
            select_row9  => Plus_row9,
            select_row10 => Plus_row10,
            select_row11 => Plus_row11,
            select_row12 => Plus_row12,
            select_row13 => Plus_row13,
            select_row14 => Plus_row14,
            select_row15 => Plus_row15,
            select_row16 => Plus_row16,

            TSF0_input => TSF0_input,
            TSF2_input => TSF2_input,
            TSF4_input => TSF4_input,
            TSF6_input => TSF6_input,
            TSF8_input => TSF8_input,

            SL0_TS => SL0_TS,
            SL2_TS => SL2_TS,
            SL4_TS => SL4_TS,
            SL6_TS => SL6_TS,
            SL8_TS => SL8_TS,

            SL0_best_TS_track1 => SL0_best_TS_track1_P,
            SL2_best_TS_track1 => SL2_best_TS_track1_P,
            SL4_best_TS_track1 => SL4_best_TS_track1_P,
            SL6_best_TS_track1 => SL6_best_TS_track1_P,
            SL8_best_TS_track1 => SL8_best_TS_track1_P,

            SL0_best_TS_track2 => SL0_best_TS_track2_P,
            SL2_best_TS_track2 => SL2_best_TS_track2_P,
            SL4_best_TS_track2 => SL4_best_TS_track2_P,
            SL6_best_TS_track2 => SL6_best_TS_track2_P,
            SL8_best_TS_track2 => SL8_best_TS_track2_P,

            SL0_best_TS_track3 => SL0_best_TS_track3_P,
            SL2_best_TS_track3 => SL2_best_TS_track3_P,
            SL4_best_TS_track3 => SL4_best_TS_track3_P,
            SL6_best_TS_track3 => SL6_best_TS_track3_P,
            SL8_best_TS_track3 => SL8_best_TS_track3_P,

            HoughCell_track1 => HoughCell_track1_P,
            HoughCell_track2 => HoughCell_track2_P,
            HoughCell_track3 => HoughCell_track3_P,
            track1_found => track1P_found,
            track2_found => track2P_found,
            track3_found => track3P_found,

            Top_clkData_s => Top_clkData_s
            );

end Behavioral;

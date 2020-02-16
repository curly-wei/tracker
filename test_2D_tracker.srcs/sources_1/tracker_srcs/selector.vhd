-------------------------------------------------------------------------------
-- Title      : 2D Selector
-- Project    : 
-------------------------------------------------------------------------------
-- File       : selector.vhd
-- Author     : Tzu-An Sheng  <tasheng@hep1.phys.ntu.edu.tw>
-- Company    : 
-- Created    : 2016-10-20
-- Last update: 2018-01-26
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Select tracks with highest pt and link their related TS'
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

entity Selector is

    port (
        rPhiPlane          : in  SquareMap;
        TSF0_input         : in  SL_InputPst(0 to NumTSF0);
        TSF2_input         : in  SL_InputPst(0 to NumTSF2);
        TSF4_input         : in  SL_InputPst(0 to NumTSF4);
        TSF6_input         : in  SL_InputPst(0 to NumTSF6);
        TSF8_input         : in  SL_InputPst(0 to NumTSF8);
        SL0_TS             : in  std_logic_vector (NumTSF0 downto 0);
        SL2_TS             : in  std_logic_vector (NumTSF2 downto 0);
        SL4_TS             : in  std_logic_vector (NumTSF4 downto 0);
        SL6_TS             : in  std_logic_vector (NumTSF6 downto 0);
        SL8_TS             : in  std_logic_vector (NumTSF8 downto 0);
        Best_TSInfo        : out TS_Info_SL_Track;
        CellIndex          : out CellInfoArray :=
        (others => (CellInfo'high => '0', others => '1'));
        old_track          : out std_logic_vector (NumTracks - 1 downto 0);
        Top_clkData_s      : in  std_logic);

end entity Selector;

architecture select2D of Selector is

    signal SL0_Hits : SL0_TSHitArray;
    signal SL2_Hits : SL2_TSHitArray;
    signal SL4_Hits : SL4_TSHitArray;
    signal SL6_Hits : SL6_TSHitArray;
    signal SL8_Hits : SL8_TSHitArray;

    signal SingleTrackX : Phis;
    signal SingleTrackY : Rhos;

    -- latency in unit of data clock
    constant latency_persistor : natural := 1;
    constant latency_highpass : natural := NumTracks + 2;
    constant latency_linkts : natural := 2;

    -- input registers
    type SL0_TSHitReg is array (0 to latency_highpass - 1) of SL0_TSHit;
    type SL2_TSHitReg is array (0 to latency_highpass - 1) of SL2_TSHit;
    type SL4_TSHitReg is array (0 to latency_highpass - 1) of SL4_TSHit;
    type SL6_TSHitReg is array (0 to latency_highpass - 1) of SL6_TSHit;
    type SL8_TSHitReg is array (0 to latency_highpass - 1) of SL8_TSHit;
    signal SL0_TS_r   : SL0_TSHitReg := (others => (others => '0'));
    signal SL2_TS_r   : SL2_TSHitReg := (others => (others => '0'));
    signal SL4_TS_r   : SL4_TSHitReg := (others => (others => '0'));
    signal SL6_TS_r   : SL6_TSHitReg := (others => (others => '0'));
    signal SL8_TS_r   : SL8_TSHitReg := (others => (others => '0'));

    type SL0_TSInfoReg is array (0 to latency_highpass - 1)
        of SL_InputPst(0 to NumTSF0);
    type SL2_TSInfoReg is array (0 to latency_highpass - 1)
        of SL_InputPst(0 to NumTSF2);
    type SL4_TSInfoReg is array (0 to latency_highpass - 1)
        of SL_InputPst(0 to NumTSF4);
    type SL6_TSInfoReg is array (0 to latency_highpass - 1)
        of SL_InputPst(0 to NumTSF6);
    type SL8_TSInfoReg is array (0 to latency_highpass - 1)
        of SL_InputPst(0 to NumTSF8);
    signal TSF0_input_r : SL0_TSInfoReg := (others => (others => (others => '0')));
    signal TSF2_input_r : SL2_TSInfoReg := (others => (others => (others => '0')));
    signal TSF4_input_r : SL4_TSInfoReg := (others => (others => (others => '0')));
    signal TSF6_input_r : SL6_TSInfoReg := (others => (others => (others => '0')));
    signal TSF8_input_r : SL8_TSInfoReg := (others => (others => (others => '0')));

    --output registers
    type CellInfoArrayReg is array(0 to latency_linkts - 1) of CellInfoArray;
    signal CellIndex_r         : CellInfoArrayReg :=
        (others => (others => (CellInfo'high => '0', others => '1')));
    type FoundReg is array(0 to latency_linkts - 1) of
        std_logic_vector(NumTracks - 1 downto 0);
    type OldTrackReg is array (0 to latency_linkts - 2) of std_logic_vector(NumTracks - 1 downto 0);
    signal old_track_r : OldTrackReg := (others => (others => '0'));

begin  -- architecture select2D

    -- latency adjustment
    prolong: process(Top_clkData_s) is
    begin
        if rising_edge(Top_clkData_s) then
            SL0_TS_r(SL0_TS_r'high) <= SL0_TS;
            SL2_TS_r(SL0_TS_r'high) <= SL2_TS;
            SL4_TS_r(SL0_TS_r'high) <= SL4_TS;
            SL6_TS_r(SL0_TS_r'high) <= SL6_TS;
            SL8_TS_r(SL0_TS_r'high) <= SL8_TS;

            SL0_TS_r(0 to SL0_TS_r'high - 1) <= SL0_TS_r(1 to SL0_TS_r'high);
            SL2_TS_r(0 to SL0_TS_r'high - 1) <= SL2_TS_r(1 to SL0_TS_r'high);
            SL4_TS_r(0 to SL0_TS_r'high - 1) <= SL4_TS_r(1 to SL0_TS_r'high);
            SL6_TS_r(0 to SL0_TS_r'high - 1) <= SL6_TS_r(1 to SL0_TS_r'high);
            SL8_TS_r(0 to SL0_TS_r'high - 1) <= SL8_TS_r(1 to SL0_TS_r'high);

            TSF0_input_r(TSF0_input_r'high) <= TSF0_input;
            TSF2_input_r(TSF2_input_r'high) <= TSF2_input;
            TSF4_input_r(TSF4_input_r'high) <= TSF4_input;
            TSF6_input_r(TSF6_input_r'high) <= TSF6_input;
            TSF8_input_r(TSF8_input_r'high) <= TSF8_input;

            TSF0_input_r(0 to SL0_TS_r'high - 1) <= TSF0_input_r(1 to SL0_TS_r'high);
            TSF2_input_r(0 to SL0_TS_r'high - 1) <= TSF2_input_r(1 to SL0_TS_r'high);
            TSF4_input_r(0 to SL0_TS_r'high - 1) <= TSF4_input_r(1 to SL0_TS_r'high);
            TSF6_input_r(0 to SL0_TS_r'high - 1) <= TSF6_input_r(1 to SL0_TS_r'high);
            TSF8_input_r(0 to SL0_TS_r'high - 1) <= TSF8_input_r(1 to SL0_TS_r'high);

            CellIndex_r(0 to FoundReg'high - 1) <= CellIndex_r(1 to FoundReg'high);
            CellIndex <= CellIndex_r(0);

            old_track_r(0 to OldTrackReg'high - 1) <= old_track_r(1 to OldTrackReg'high);
            old_track <= old_track_r(0);
        end if;
    end process prolong;


    HighPass_1: entity work.HighPass
        generic map (
            preserved => 0)
        port map (
            Top_clkData_s  => Top_clkData_s,
            WholeTrackMap  => rPhiPlane,
            SingleTrackX   => SingleTrackX,
            SingleTrackY   => SingleTrackY,
            CellIndex      => CellIndex_r(CellIndex_r'high),
            old_track      => old_track_r(old_track_r'high));

    InverseMap_1: entity work.InverseMap
        port map (
            Top_clkData_s   => Top_clkData_s,
            SingleTrackX   => SingleTrackX,
            SingleTrackY   => SingleTrackY,
            SL0_TS          => SL0_TS_r(0),
            SL2_TS          => SL2_TS_r(0),
            SL4_TS          => SL4_TS_r(0),
            SL6_TS          => SL6_TS_r(0),
            SL8_TS          => SL8_TS_r(0),
            SL0_Hits        => SL0_Hits,
            SL2_Hits        => SL2_Hits,
            SL4_Hits        => SL4_Hits,
            SL6_Hits        => SL6_Hits,
            SL8_Hits        => SL8_Hits);

    LinkTS_1: entity work.LinkTS
        port map (
            Top_clkData_s => Top_clkData_s,
            SL0_Hits      => SL0_Hits,
            SL2_Hits      => SL2_Hits,
            SL4_Hits      => SL4_Hits,
            SL6_Hits      => SL6_Hits,
            SL8_Hits      => SL8_Hits,
            TSF0_input    => TSF0_input_r(0),
            TSF2_input    => TSF2_input_r(0),
            TSF4_input    => TSF4_input_r(0),
            TSF6_input    => TSF6_input_r(0),
            TSF8_input    => TSF8_input_r(0),
            Best_TSInfo   => Best_TSInfo);

end architecture select2D;

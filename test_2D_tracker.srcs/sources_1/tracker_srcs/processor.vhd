-------------------------------------------------------------------------------
-- Title      : Core Processor of 2D tracker 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : processor.vhd
-- Author     : Tzu-An Sheng  <tasheng@hep1.phys.ntu.edu.tw>
-- Company    : 
-- Created    : 2016-10-21
-- Last update: 2018-02-08
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 NumTSF
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-10-21  1.0      tristesse	Created
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.types.all;

entity Processor is

    port (

        Best_TSInfo   : out TS_Info_SL_Track;
        CellIndex     : out CellInfoArray;
        track_found   : out std_logic_vector (NumTracks - 1 downto 0)  := (others => '0');
        old_track     : out std_logic_vector (NumTracks - 1 downto 0)  := (others => '0');
        charge        : out std_logic_vector (11 downto 0)  := (others => '0');
        SL0_TS        : in  std_logic_vector (NumTSF0 downto 0);
        SL2_TS        : in  std_logic_vector (NumTSF2 downto 0);
        SL4_TS        : in  std_logic_vector (NumTSF4 downto 0);
        SL6_TS        : in  std_logic_vector (NumTSF6 downto 0);
        SL8_TS        : in  std_logic_vector (NumTSF8 downto 0);
        TSF0_input    : in  SL_InputPst(0 to NumTSF0):= (others => (others => '0'));
        TSF2_input    : in  SL_InputPst(0 to NumTSF2):= (others => (others => '0'));
        TSF4_input    : in  SL_InputPst(0 to NumTSF4):= (others => (others => '0'));
        TSF6_input    : in  SL_InputPst(0 to NumTSF6):= (others => (others => '0'));
        TSF8_input    : in  SL_InputPst(0 to NumTSF8):= (others => (others => '0'));
        Top_clkData_s : in  std_logic);

end entity Processor;

architecture compute of Processor is

    constant CellID_NOHIT : std_logic_vector(CellInfo'range) :=
        (CellInfo'high => '0', others => '1');
    -- signal HoughFineMap : FineMap;
    signal rPhiPlane : SquareMap;

    signal SL0_TSHit        : SL_Hit (NumTSF0 downto 0);
    signal SL2_TSHit        : SL_Hit (NumTSF2 downto 0);
    signal SL4_TSHit        : SL_Hit (NumTSF4 downto 0);
    signal SL6_TSHit        : SL_Hit (NumTSF6 downto 0);
    signal SL8_TSHit        : SL_Hit (NumTSF8 downto 0);

    signal cell_ID          : CellInfoArray := (others => CellID_NOHIT);
    signal cell_ID_r        : CellInfoArray := Cell_ID;
    --subtype rinterval is integer range - HoughFineMapHeight/2 to HoughFineMapHeight/2;
    subtype rinterval is integer range - HoughFineMapHeight/2 to 2**(rBitSize - 1) - 1;
    type int_array is array (natural range <>) of rinterval;
    signal int_r :          int_array(0 to NumTracks - 1) := (others => 0);

    signal Best_TSInfo_s    : TS_Info_SL_Track;
    -- persistence suppression
    signal cellindex_change : std_logic_vector(0 to NumTracks - 1);
    subtype TS_Info_part is std_logic_vector(11 downto 0);
    type TS_Info_SL_part is array (0 to 4) of TS_Info_part;
    type TS_Info_SL_Track_part is array (0 to NumTracks - 1) of TS_Info_SL_part;
    signal ts_update : TS_Info_SL_Track_part := (others => (others => (others => '0')));
    signal ts_update_r : TS_Info_SL_Track_part := (others => (others => (others => '0')));
    signal tsinfo_change  : std_logic_vector(NumTracks - 1 downto 0) := (others => '0');
    constant ts_update_null : TS_Info_part := (others => '0');

    signal old_track_s      : std_logic_vector (NumTracks - 1 downto 0) := (others => '1');
begin  -- architecture process

    -- calculate charge
    calcharge: for trk in 0 to NumTracks - 1 generate
        int_r(trk) <= to_integer(signed(
            cell_ID(trk)(CellInfo'high downto CellInfo'high - rBitSize + 1)));
        charge(11 - 2*trk downto 11 - 2*trk - 1) <= "01" when int_r(trk) > 0 else
                                                    "10" when int_r(trk) < 0 else
                                                    "11";
    end generate calcharge;

    -- generate or suppress track_found signals
    NewTrack: for trk in 0 to NumTracks - 1 generate
        cellindex_change(trk) <= '1' when cell_ID(trk) /= cell_ID_r(trk) and
                                 cell_ID(trk) /= CellID_NOHIT else
                                 '0';
        gatherSL: for isl in 0 to 4 generate
            ts_update(trk)(isl) <= Best_TSInfo_s(trk)(isl)(20 downto 13) & Best_TSInfo_s(trk)(isl)(3 downto 0);
        end generate;
        tsinfo_change(trk) <= '1' when ((ts_update(trk)(0) /= ts_update_r(trk)(0)) or
                                        (ts_update(trk)(1) /= ts_update_r(trk)(1)) or
                                        (ts_update(trk)(2) /= ts_update_r(trk)(2)) or
                                        (ts_update(trk)(3) /= ts_update_r(trk)(3)) or
                                        (ts_update(trk)(4) /= ts_update_r(trk)(4))) and
                              not (ts_update(trk)(0) = ts_update_null and
                                   ts_update(trk)(1) = ts_update_null and
                                   ts_update(trk)(2) = ts_update_null and
                                   ts_update(trk)(3) = ts_update_null and
                                   ts_update(trk)(4) = ts_update_null) else
                              '0';
        track_found(trk) <= cellindex_change(trk) or tsinfo_change(trk);

    end generate;

    process(top_clkdata_s) is
    begin
        if rising_edge(top_clkdata_s) then
            cell_ID_r <= cell_ID;
            ts_update_r <= ts_update;
        end if;
    end process;

    CellIndex <= cell_ID;
    Best_TSInfo <= Best_TSInfo_s;
    old_track <= old_track_s;

    PriMap0: for i in 0 to NumTSF0 generate
        SL0_TSHit(i)(1) <= SL0_TS(i) and not TSF0_input(i)(1) and TSF0_input(i)(0);
        SL0_TSHit(i)(2) <= SL0_TS(i) and TSF0_input(i)(1) and not TSF0_input(i)(0);
        SL0_TSHit(i)(3) <= SL0_TS(i) and TSF0_input(i)(1) and TSF0_input(i)(0);
    end generate PriMap0;

    PriMap2: for i in 0 to NumTSF2 generate
        SL2_TSHit(i)(1) <= SL2_TS(i) and not TSF2_input(i)(1) and TSF2_input(i)(0);
        SL2_TSHit(i)(2) <= SL2_TS(i) and TSF2_input(i)(1) and not TSF2_input(i)(0);
        SL2_TSHit(i)(3) <= SL2_TS(i) and TSF2_input(i)(1) and TSF2_input(i)(0);
    end generate PriMap2;

    PriMap4: for i in 0 to NumTSF4 generate
        SL4_TSHit(i)(1) <= SL4_TS(i) and not TSF4_input(i)(1) and TSF4_input(i)(0);
        SL4_TSHit(i)(2) <= SL4_TS(i) and TSF4_input(i)(1) and not TSF4_input(i)(0);
        SL4_TSHit(i)(3) <= SL4_TS(i) and TSF4_input(i)(1) and TSF4_input(i)(0);
    end generate PriMap4;

    PriMap6: for i in 0 to NumTSF6 generate
        SL6_TSHit(i)(1) <= SL6_TS(i) and not TSF6_input(i)(1) and TSF6_input(i)(0);
        SL6_TSHit(i)(2) <= SL6_TS(i) and TSF6_input(i)(1) and not TSF6_input(i)(0);
        SL6_TSHit(i)(3) <= SL6_TS(i) and TSF6_input(i)(1) and TSF6_input(i)(0);
    end generate PriMap6;

    PriMap8: for i in 0 to NumTSF8 generate
        SL8_TSHit(i)(1) <= SL8_TS(i) and not TSF8_input(i)(1) and TSF8_input(i)(0);
        SL8_TSHit(i)(2) <= SL8_TS(i) and TSF8_input(i)(1) and not TSF8_input(i)(0);
        SL8_TSHit(i)(3) <= SL8_TS(i) and TSF8_input(i)(1) and TSF8_input(i)(0);
    end generate PriMap8;

    Finder_1: entity work.Finder
        port map (
            rPhiPlane     => rPhiPlane,
            SL0_TS        => SL0_TSHit,
            SL2_TS        => SL2_TSHit,
            SL4_TS        => SL4_TSHit,
            SL6_TS        => SL6_TSHit,
            SL8_TS        => SL8_TSHit,
            Top_clkData_s => Top_clkData_s);

    Selector_1: entity work.Selector
        port map (
            rPhiPlane     => rPhiPlane,
            TSF0_input    => TSF0_input,
            TSF2_input    => TSF2_input,
            TSF4_input    => TSF4_input,
            TSF6_input    => TSF6_input,
            TSF8_input    => TSF8_input,
            SL0_TS        => SL0_TS,
            SL2_TS        => SL2_TS,
            SL4_TS        => SL4_TS,
            SL6_TS        => SL6_TS,
            SL8_TS        => SL8_TS,
            Best_TSInfo   => Best_TSInfo_s,
            CellIndex     => cell_ID,
            old_track     => old_track_s,
            Top_clkData_s => Top_clkData_s);
end architecture compute;

-------------------------------------------------------------------------------
-- Title      : Inverse Map
-- Project    : 
-------------------------------------------------------------------------------
-- File       : InverseMap.vhd
-- Author     : Tzu-An Sheng  <tasheng@hep1.phys.ntu.edu.tw>
-- Company    : 
-- Created    : 2016-10-21
-- Last update: 2016-11-04
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-10-21  1.0      tristesse	Created
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.types.all;

entity InverseMap is

    port (
        Top_clkData_s   : in  std_logic;
        SingleTrackX    : in  Phis;
        SingleTrackY    : in  Rhos;
        SL0_TS          : in  SL0_TSHit;
        SL2_TS          : in  SL2_TSHit;
        SL4_TS          : in  SL4_TSHit;
        SL6_TS          : in  SL6_TSHit;
        SL8_TS          : in  SL8_TSHit;
        SL0_Hits        : out SL0_TSHitArray;
        SL2_Hits        : out SL2_TSHitArray;
        SL4_Hits        : out SL4_TSHitArray;
        SL6_Hits        : out SL6_TSHitArray;
        SL8_Hits        : out SL8_TSHitArray);

end entity InverseMap;

architecture part2 of InverseMap is

    signal SL0_TS_Trk: SL0_TSHitArray;
    signal SL2_TS_Trk: SL2_TSHitArray;
    signal SL4_TS_Trk: SL4_TSHitArray;
    signal SL6_TS_Trk: SL6_TSHitArray;
    signal SL8_TS_Trk: SL8_TSHitArray;


    signal InvMaps : InvMapArray(0 to NumTracks - 1);

    type LogicVec is array (integer range <>) of std_logic;
    subtype RhoEX is LogicVec(FineMap'low - 1 to FineMap'high + 1);
    subtype PhiEX is LogicVec(FineMapRow'low - 1 to FineMapRow'high + 1);
    type RhoEXArray is array (0 to NumTracks - 1) of RhoEX;
    type PhiEXArray is array (0 to NumTracks - 1) of PhiEx;
    signal SingleTrackXEX : PhiEXArray;
    signal SingleTrackYEX : RhoEXArray;

begin  -- architecture part2

    -- Fill Hough Map based on Fine map content
    gentrk: for trk in 0 to NumTracks - 1 generate
        genyex: for y in FineMap'range generate
            SingleTrackYEX(trk)(y) <= SingleTrackY(trk)(y);
        end generate genyex;
        genxex: for x in FineMapRow'range generate
            SingleTrackXEX(trk)(x) <= SingleTrackX(trk)(x);
        end generate genxex;
        SingleTrackYEX(trk)(RhoEX'low) <= '0';
        SingleTrackYEX(trk)(RhoEX'high) <= '0';
        SingleTrackXEX(trk)(PhiEx'low) <= '0';
        SingleTrackXEX(trk)(PhiEx'high) <= '0';
        genx: for x in InvMapRow'range generate
            geny: for y in InvMap'range generate
                InvMaps(trk)(y)(x) <= (SingleTrackXEX(trk)(2*x - 1) or
                                       SingleTrackXEX(trk)(2*x    ) or
                                       SingleTrackXEX(trk)(2*x + 1)) and
                                      (SingleTrackYEX(trk)(2*y - 1) or
                                       SingleTrackYEX(trk)(2*y    ) or
                                       SingleTrackYEX(trk)(2*y + 1));
            end generate;
        end generate;
    end generate;


    InverseTracks: for trk in SingleTrackX'range generate
        InverseMapSL0: entity work.InverseMap0
            port map (
                SL0_TS => SL0_TS_Trk(trk),
                M      => InvMaps(trk));
        SL0_Hits(trk) <= SL0_TS_Trk(trk) and SL0_TS;

        InverseMapSL2: entity work.InverseMap2
            port map (
                SL2_TS => SL2_TS_Trk(trk),
                M      => InvMaps(trk));
        SL2_Hits(trk) <= SL2_TS_Trk(trk) and SL2_TS;

        InverseMapSL4: entity work.InverseMap4
            port map (
                SL4_TS => SL4_TS_Trk(trk),
                M      => InvMaps(trk));
        SL4_Hits(trk) <= SL4_TS_Trk(trk) and SL4_TS;

        InverseMapSL6: entity work.InverseMap6
            port map (
                SL6_TS => SL6_TS_Trk(trk),
                M      => InvMaps(trk));
        SL6_Hits(trk) <= SL6_TS_Trk(trk) and SL6_TS;

        InverseMapSL8: entity work.InverseMap8
            port map (
                SL8_TS => SL8_TS_Trk(trk),
                M      => InvMaps(trk));
        SL8_Hits(trk) <= SL8_TS_Trk(trk) and SL8_TS;

    end generate InverseTracks;

end architecture part2;

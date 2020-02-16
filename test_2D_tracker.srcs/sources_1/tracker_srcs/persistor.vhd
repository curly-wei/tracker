-------------------------------------------------------------------------------
-- Title      : Persistor
-- Project    : 
-------------------------------------------------------------------------------
-- File       : persistor.vhd
-- Author     : Tzu-An Sheng  <tasheng@hep1.phys.ntu.edu.tw>
-- Company    : NTU & belle2 cdctrg
-- Created    : 2016-04-03
-- Last update: 2018-01-30
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: handle IO and persistence of 2D tracker
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-04-03  1.0      tristesse	Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
-- use IEEE.STD_LOGIC_ARITH.all;
-- use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

use work.types.all;

entity persistor is
    port (
        TSF0_input_i     : in  std_logic_vector (339 downto 0) := (others => '1');
        TSF2_input_i     : in  std_logic_vector (339 downto 0) := (others => '1');
        TSF4_input_i     : in  std_logic_vector (339 downto 0) := (others => '1');
        TSF6_input_i     : in  std_logic_vector (339 downto 0) := (others => '1');
        TSF8_input_i     : in  std_logic_vector (339 downto 0) := (others => '1');
        Main_out         : out std_logic_vector (731 downto 0) := (others => '0');
        old_track        : out std_logic_vector (5 downto 0) := (others => '0');
        -- Z : 6 bits for found_track
        -- for each track:
        -- A : 2 bit for charge(positive=01, negative=10, undefined=11);
        -- B : 7 + 7 b	its for Hough Cell ID.
        -- C : 105 bits for TS_Info(21 bits for each SuperLayer, 21 x 5=105.)
        --     same as output from TSF
        -- 121 bits per track
        -- 726 + 6 = 732 bits
        Top_clkData_s    : in  std_logic := '1');

end entity persistor;

architecture internal of persistor is
    -- integer overflow
    type tsfIds is array (0 to NumTS) of natural range 0 to 255;
    signal tsf0id        : tsfIds := (others => NumTSF0 + 1);
    signal tsf2id        : tsfIds := (others => NumTSF2 + 1);
    signal tsf4id        : tsfIds := (others => NumTSF4 + 1);
    signal tsf6id        : tsfIds := (others => NumTSF6 + 1);
    signal tsf8id        : tsfIds := (others => NumTSF8 + 1);
    signal tsfint0id     : tsfIds := (others => NumTSF0 + 1);
    signal tsfint2id     : tsfIds := (others => NumTSF2 + 1);
    signal tsfint4id     : tsfIds := (others => NumTSF4 + 1);
    signal tsfint6id     : tsfIds := (others => NumTSF6 + 1);
    signal tsfint8id     : tsfIds := (others => NumTSF8 + 1);

    signal tsf0Hit          : std_logic_vector(NumTSF0+1 downto 0) := (others => '0');
    signal tsf2Hit          : std_logic_vector(NumTSF2+1 downto 0) := (others => '0');
    signal tsf4Hit          : std_logic_vector(NumTSF4+1 downto 0) := (others => '0');
    signal tsf6Hit          : std_logic_vector(NumTSF6+1 downto 0) := (others => '0');
    signal tsf8Hit          : std_logic_vector(NumTSF8+1 downto 0) := (others => '0');
    signal tsf0RecentHit    : std_logic_vector(NumTSF0 downto 0)  := (others => '0');
    signal tsf2RecentHit    : std_logic_vector(NumTSF2 downto 0)  := (others => '0');
    signal tsf4RecentHit    : std_logic_vector(NumTSF4 downto 0)  := (others => '0');
    signal tsf6RecentHit    : std_logic_vector(NumTSF6 downto 0)  := (others => '0');
    signal tsf8RecentHit    : std_logic_vector(NumTSF8 downto 0)  := (others => '0');
    signal tsf0Info         : SL_InputPst(0 to NumTSF0+1)  := (others =>(others => '0'));
    signal tsf2Info         : SL_InputPst(0 to NumTSF2+1)  := (others =>(others => '0'));
    signal tsf4Info         : SL_InputPst(0 to NumTSF4+1)  := (others =>(others => '0'));
    signal tsf6Info         : SL_InputPst(0 to NumTSF6+1)  := (others =>(others => '0'));
    signal tsf8Info         : SL_InputPst(0 to NumTSF8+1)  := (others =>(others => '0'));
    signal tsf0HitPipe      : tsfPipe(0 to NumTSF0) := (others => (others => '0'));
    signal tsf2HitPipe      : tsfPipe(0 to NumTSF2) := (others => (others => '0'));
    signal tsf4HitPipe      : tsfPipe(0 to NumTSF4) := (others => (others => '0'));
    signal tsf6HitPipe      : tsfPipe(0 to NumTSF6) := (others => (others => '0'));
    signal tsf8HitPipe      : tsfPipe(0 to NumTSF8) := (others => (others => '0'));
    constant tsfNoHitInPipe : std_logic_vector(15 downto 0) := (others => '0');

    signal TSF0_input     : std_logic_vector(339 downto 0) := (others => '1');
    signal TSF2_input     : std_logic_vector(339 downto 0) := (others => '1');
    signal TSF4_input     : std_logic_vector(339 downto 0) := (others => '1');
    signal TSF6_input     : std_logic_vector(339 downto 0) := (others => '1');
    signal TSF8_input     : std_logic_vector(339 downto 0) := (others => '1');
    signal SL0_TS         : std_logic_vector(NumTSF0 downto 0);
    signal SL2_TS         : std_logic_vector(NumTSF2 downto 0);
    signal SL4_TS         : std_logic_vector(NumTSF4 downto 0);
    signal SL6_TS         : std_logic_vector(NumTSF6 downto 0);
    signal SL8_TS         : std_logic_vector(NumTSF8 downto 0);

    -- persisted tsf input
    signal TSF0_input_pst : SL_InputPst(0 to NumTSF0) := (others => (others => '0'));
    signal TSF2_input_pst : SL_InputPst(0 to NumTSF2) := (others => (others => '0'));
    signal TSF4_input_pst : SL_InputPst(0 to NumTSF4) := (others => (others => '0'));
    signal TSF6_input_pst : SL_InputPst(0 to NumTSF6) := (others => (others => '0'));
    signal TSF8_input_pst : SL_InputPst(0 to NumTSF8) := (others => (others => '0'));

    -- 2D output to be sent to 2D Fitter or 3D tracker
    signal output         : std_logic_vector(731 downto 0) := (others => '0');

    signal charge         : std_logic_vector(11 downto 0) := (others => '0');

    signal track_found    : std_logic_vector(NumTracks - 1 downto 0) := (others => '0');
    signal old_track_out  : std_logic_vector(NumTracks - 1 downto 0) := (others => '0');
    constant TSFInfo_Null : std_logic_vector(20 downto 0) := (others => '0');
    constant trk_out_null : std_logic_vector(120 downto 0) := (117 downto 105 => '1', others => '0');
    -- Hit assignment
    procedure tsfHitAssign (
        signal tsfId     : in    tsfIds;
        signal tsfHit    : inout std_logic_vector;  -- tsf hit map
        signal tsfInfo   : inout SL_InputPst;          -- tsf extra info
        signal tsf_input : in    std_logic_vector) is
    begin  -- procedure tsfHitAssign
        tsfHit(tsfHit'range) <= (others => '0');
        -- Do not clear Hit Info to account for persistence
        --tsfInfo(tsfInfo'range) <= (others => TSFInfo_Null);
        for i in 0 to NumTS loop
            tsfHit(tsfId(i))  <= '1';
				
-- Corrected by ytlai 2019/05/09
--            tsfInfo(tsfId(i)) <= tsf_input ((21 * i + 20) downto (21 * i));
            tsfInfo(tsfId(i)) <= tsf_input ((330 - 21*i) downto (310 - 21*i));
        end loop;
    end procedure tsfHitAssign;

    signal Best_TSInfo   : TS_Info_SL_Track;
    signal CellIndex     : CellInfoArray;

begin  -- architecture persist

    Processor_1: entity work.Processor
        port map (
            Best_TSInfo   => Best_TSInfo,
            CellIndex     => CellIndex,
            track_found   => track_found,
            old_track     => old_track_out,
            charge        => charge,
            SL0_TS        => SL0_TS,
            SL2_TS        => SL2_TS,
            SL4_TS        => SL4_TS,
            SL6_TS        => SL6_TS,
            SL8_TS        => SL8_TS,
            TSF0_input    => TSF0_input_pst,
            TSF2_input    => TSF2_input_pst,
            TSF4_input    => TSF4_input_pst,
            TSF6_input    => TSF6_input_pst,
            TSF8_input    => TSF8_input_pst,
            Top_clkData_s => Top_clkData_s);

    -- reverse the order of tracks: trk 0 is the track with highest pt
    OutputPerTrack: for trk in 0 to NumTracks - 1 generate
        output(output'left - trk) <= track_found(trk);
        output(121*(6 - trk) - 1 downto 121*(5 - trk)) <=
            charge(2*(5 - trk) + 1 downto 2*(5 - trk)) &
            CellIndex(trk) &
            Best_TSInfo(trk)(0) &
            Best_TSInfo(trk)(1) &
            Best_TSInfo(trk)(2) &
            Best_TSInfo(trk)(3) &
            Best_TSInfo(trk)(4) when track_found(trk) = '1' else (others => '0');
        old_track(old_track'left - trk) <= old_track_out(trk);
     end generate OutputPerTrack;

    TSF0_input <= TSF0_input_i;
    TSF2_input <= TSF2_input_i;
    TSF4_input <= TSF4_input_i;
    TSF6_input <= TSF6_input_i;
    TSF8_input <= TSF8_input_i;

    tsfHitId : for i in 0 to NumTS generate
        -- When using different Hough maps for different priority positions,
        -- NOHIT will be discarded in processor.
        -- tsf0id(i) <= conv_integer(TSF0_input
        --                           ((21 * i + 20) downto (21 * i + 13))) when
        --              TSF0_input(21*i + 3 downto 21*i + 2) /= "00" else
        --              Numtsf0 + 1;
        -- tsf2id(i) <= conv_integer(TSF2_input
        --                           ((21 * i + 20) downto (21 * i + 13))) when
        --              TSF2_input(21*i + 3 downto 21*i + 2) /= "00" else
        --              Numtsf2 + 1;
        -- tsf4id(i) <= conv_integer(TSF4_input
        --                           ((21 * i + 20) downto (21 * i + 13))) when
        --              TSF4_input(21*i + 3 downto 21*i + 2) /= "00" else
        --              Numtsf4 + 1;
        -- tsf6id(i) <= conv_integer(TSF6_input
        --                           ((21 * i + 20) downto (21 * i + 13))) when
        --              TSF6_input(21*i + 3 downto 21*i + 2) /= "00" else
        --              Numtsf6 + 1;
        -- tsf8id(i) <= conv_integer(TSF8_input
        --                           ((21 * i + 20) downto (21 * i + 13))) when
        --              TSF8_input(21*i + 3 downto 21*i + 2) /= "00" else
        --              Numtsf8 + 1;
		  
-- Corrected by ytlai 2019/05/09
--        tsf0id(i) <= to_integer(unsigned(TSF0_input ((21 * i + 20) downto (21 * i + 13))));
--        tsf2id(i) <= to_integer(unsigned(TSF2_input ((21 * i + 20) downto (21 * i + 13))));
--        tsf4id(i) <= to_integer(unsigned(TSF4_input ((21 * i + 20) downto (21 * i + 13))));
--        tsf6id(i) <= to_integer(unsigned(TSF6_input ((21 * i + 20) downto (21 * i + 13))));
--        tsf8id(i) <= to_integer(unsigned(TSF8_input ((21 * i + 20) downto (21 * i + 13))));
        tsf0id(i) <= to_integer(unsigned(TSF0_input ((330 - 21*i) downto (323 - 21*i))));
        tsf2id(i) <= to_integer(unsigned(TSF2_input ((330 - 21*i) downto (323 - 21*i))));
        tsf4id(i) <= to_integer(unsigned(TSF4_input ((330 - 21*i) downto (323 - 21*i))));
        tsf6id(i) <= to_integer(unsigned(TSF6_input ((330 - 21*i) downto (323 - 21*i))));
        tsf8id(i) <= to_integer(unsigned(TSF8_input ((330 - 21*i) downto (323 - 21*i))));
    end generate;
    tsfintermediate : for i in 0 to NumTS generate
        tsfint0id(i) <= tsf0id(i) when tsf0id(i) < Numtsf0 + 1 else
                        Numtsf0 + 1;
        tsfint2id(i) <= tsf2id(i) when tsf2id(i) < Numtsf2 + 1 else
                        Numtsf2 + 1;
        tsfint4id(i) <= tsf4id(i) when tsf4id(i) < Numtsf4 + 1 else
                        Numtsf4 + 1;
        tsfint6id(i) <= tsf6id(i) when tsf6id(i) < Numtsf6 + 1 else
                        Numtsf6 + 1;
        tsfint8id(i) <= tsf8id(i) when tsf8id(i) < Numtsf8 + 1 else
                        Numtsf8 + 1;
    end generate;

    process (Top_clkData_s)
    begin
        if rising_edge(Top_clkData_s) then
            -- Clear hit map
            tsf0Hit <= (others => '0');
            tsf2Hit <= (others => '0');
            tsf4Hit <= (others => '0');
            tsf6Hit <= (others => '0');
            tsf8Hit <= (others => '0');

            -- assign to hitmap and extra map
            tsfHitAssign(tsfint0id, tsf0Hit, tsf0Info, TSF0_input);
            tsfHitAssign(tsfint2id, tsf2Hit, tsf2Info, TSF2_input);
            tsfHitAssign(tsfint4id, tsf4Hit, tsf4Info, TSF4_input);
            tsfHitAssign(tsfint6id, tsf6Hit, tsf6Info, TSF6_input);
            tsfHitAssign(tsfint8id, tsf8Hit, tsf8Info, TSF8_input);

            -- Pipe shift
            tsf0HitPipeShift : for i in 0 to NumTSF0 loop
                tsf0HitPipe(i) <= tsf0HitPipe(i)(14 downto 0) & tsf0Hit(i);
            end loop;
            tsf2HitPipeShift : for i in 0 to NumTSF2 loop
                tsf2HitPipe(i) <= tsf2HitPipe(i)(14 downto 0) & tsf2Hit(i);
            end loop;
            tsf4HitPipeShift : for i in 0 to NumTSF4 loop
                tsf4HitPipe(i) <= tsf4HitPipe(i)(14 downto 0) & tsf4Hit(i);
            end loop;
            tsf6HitPipeShift : for i in 0 to NumTSF6 loop
                tsf6HitPipe(i) <= tsf6HitPipe(i)(14 downto 0) & tsf6Hit(i);
            end loop;
            tsf8HitPipeShift : for i in 0 to NumTSF8 loop
                tsf8HitPipe(i) <= tsf8HitPipe(i)(14 downto 0) & tsf8Hit(i);
            end loop;
        end if;
    end process;

    -- TSF Hit in recent 16 clocks
    tsfRecentHit0 : for i in 0 to NumTSF0 generate
        tsf0RecentHit(i) <= '1' when (tsf0HitPipe(i)(14 downto 0) & tsf0Hit(i) /= tsfNoHitInPipe) else
                            '0';
    end generate;

    tsfRecentHit2 : for i in 0 to NumTSF2 generate
        tsf2RecentHit(i) <= '1' when (tsf2HitPipe(i)(14 downto 0) & tsf2Hit(i) /= tsfNoHitInPipe) else
                            '0';
    end generate;

    tsfRecentHit4 : for i in 0 to NumTSF4 generate
        tsf4RecentHit(i) <= '1' when (tsf4HitPipe(i)(14 downto 0) & tsf4Hit(i) /= tsfNoHitInPipe) else
                            '0';
    end generate;

    tsfRecentHit6 : for i in 0 to NumTSF6 generate
        tsf6RecentHit(i) <= '1' when (tsf6HitPipe(i)(14 downto 0) & tsf6Hit(i) /= tsfNoHitInPipe) else
                            '0';
    end generate;

    tsfRecentHit8 : for i in 0 to NumTSF8 generate
        tsf8RecentHit(i) <= '1' when (tsf8HitPipe(i)(14 downto 0) & tsf8Hit(i) /= tsfNoHitInPipe) else
                            '0';
    end generate;

    -- Output hit map
    SL0_TS <= tsf0RecentHit;
    SL2_TS <= tsf2RecentHit;
    SL4_TS <= tsf4RecentHit;
    SL6_TS <= tsf6RecentHit;
    SL8_TS <= tsf8RecentHit;

    TSF0_PST_Mask: for i in 0 to NumTSF0 generate
        TSF0_input_pst(i)(20 downto 2) <= tsf0Info(i)(20 downto 2);
        TSF0_input_pst(i)(1 downto 0) <= tsf0Info(i)(1 downto 0) when SL0_TS(i) = '1' else "00";
    end generate;

    TSF2_PST_Mask: for i in 0 to NumTSF2 generate
        TSF2_input_pst(i)(20 downto 2) <= tsf2Info(i)(20 downto 2);
        TSF2_input_pst(i)(1 downto 0) <= tsf2Info(i)(1 downto 0) when SL2_TS(i) = '1' else "00";
    end generate;

    TSF4_PST_Mask: for i in 0 to NumTSF4 generate
        TSF4_input_pst(i)(20 downto 2) <= tsf4Info(i)(20 downto 2);
        TSF4_input_pst(i)(1 downto 0) <= tsf4Info(i)(1 downto 0) when SL4_TS(i) = '1' else "00";
    end generate;

    TSF6_PST_Mask: for i in 0 to NumTSF6 generate
        TSF6_input_pst(i)(20 downto 2) <= tsf6Info(i)(20 downto 2);
        TSF6_input_pst(i)(1 downto 0) <= tsf6Info(i)(1 downto 0) when SL6_TS(i) = '1' else "00";
    end generate;

    TSF8_PST_Mask: for i in 0 to NumTSF8 generate
        TSF8_input_pst(i)(20 downto 2) <= tsf8Info(i)(20 downto 2);
        TSF8_input_pst(i)(1 downto 0) <= tsf8Info(i)(1 downto 0) when SL8_TS(i) = '1' else "00";
    end generate;

    Main_out <= output;

end architecture internal;

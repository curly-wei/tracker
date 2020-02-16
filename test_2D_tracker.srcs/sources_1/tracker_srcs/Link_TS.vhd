library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.types.all;

entity LinkTS is

    port (
        Top_clkData_s : in  std_logic;
        SL0_Hits      : in  SL0_TSHitArray;
        SL2_Hits      : in  SL2_TSHitArray;
        SL4_Hits      : in  SL4_TSHitArray;
        SL6_Hits      : in  SL6_TSHitArray;
        SL8_Hits      : in  SL8_TSHitArray;
        TSF0_input    : in  SL_InputPst(0 to NumTSF0);
        TSF2_input    : in  SL_InputPst(0 to NumTSF2);
        TSF4_input    : in  SL_InputPst(0 to NumTSF4);
        TSF6_input    : in  SL_InputPst(0 to NumTSF6);
        TSF8_input    : in  SL_InputPst(0 to NumTSF8);
        Best_TSInfo   : out TS_Info_SL_Track);

end entity LinkTS;

architecture part3 of LinkTS is

    component select_ts is
        generic (
            NumTSF : natural := NumTSF0);
        port (
            Top_clkData_s : in  std_logic;
            track_hit  : in  std_logic_vector (NumTSF downto 0) := (others => '0');
            input_info : in  SL_InputPst(0 to NumTSF)           := (others => (others => '0'));
            best_TS    : out std_logic_vector (20 downto 0)     := (others => '0'));
    end component select_ts;

begin
    SelectTSPerTrack: for trk in 0 to NumTracks - 1 generate
        SL0_track : select_ts
            generic map(NumTSF => NumTSF0)
            port map(
                Top_clkData_s => Top_clkData_s,
                track_hit     => SL0_Hits(trk),
                input_info    => TSF0_input,
                best_TS       => Best_TSInfo(trk)(0));

        SL2_track : select_ts
            generic map(NumTSF => NumTSF2)
            port map(
                Top_clkData_s => Top_clkData_s,
                track_hit     => SL2_Hits(trk),
                input_info    => TSF2_input,
                best_TS       => Best_TSInfo(trk)(1));

        SL4_track : select_ts
            generic map(NumTSF => NumTSF4)
            port map(
                Top_clkData_s => Top_clkData_s,
                track_hit     => SL4_Hits(trk),
                input_info    => TSF4_input,
                best_TS       => Best_TSInfo(trk)(2));

        SL6_track : select_ts
            generic map(NumTSF => NumTSF6)
            port map(
                Top_clkData_s => Top_clkData_s,
                track_hit     => SL6_Hits(trk),
                input_info    => TSF6_input,
                best_TS       => Best_TSInfo(trk)(3));

        SL8_track : select_ts
            generic map(NumTSF => NumTSF8)
            port map(
                Top_clkData_s => Top_clkData_s,
                track_hit     => SL8_Hits(trk),
                input_info    => TSF8_input,
                best_TS       => Best_TSInfo(trk)(4));
    end generate SelectTSPerTrack;

end part3;

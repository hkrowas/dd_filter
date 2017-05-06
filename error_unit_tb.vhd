----------------------------------------------------------------------------
--
--  ERROR_UNIT Test Bench
--
--  This is the test bernch for the error unit of the DD filter (error_unit.vhd)
--
--  Revision History:
--     2017-05-05  Harrison Krowas     Initial revision.
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.tap_array.all;

entity ERROR_UNIT_TB is
end ERROR_UNIT_TB;

architecture ERROR_UNIT_TB_ARCH of ERROR_UNIT_TB is
    component ERROR_UNIT
        generic (
            n_taps  :  integer := 16
        );
        port (
            data_in    :  in  tap_array(0 to n_taps - 1);
            data_out   :  in  com;
            taps_in    :  in  tap_array(0 to n_taps - 1);
            taps       :  out tap_array(0 to n_taps - 1);
            error_out  :  out com;
            d          :  out com
        );
    end component;
    signal n_taps : integer := 16;
    signal data_in : tap_array(0 to n_taps - 1) :=
     ((x"4201", x"423B"), (x"EBA0", x"0010"), (x"AAAA", x"BBBB"), (x"0000", x"0000")
    , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
    , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
    , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"));
    signal data_out : com;
    signal taps_in : tap_array(0 to n_taps - 1) :=
    ((x"2222", x"423B"), (x"0000", x"0010"), (x"DDDD", x"EEE0"), (x"0000", x"0000")
   , (x"0000", x"0000"), (x"0230", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
   , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"043D", x"42EF")
   , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"));
   signal taps  :  tap_array(0 to n_taps - 1);
   signal error_out  :  com;
   signal d : com;
   --signal taps : tap_array(0 to n_taps -1) :=
   signal END_SIM : BOOLEAN := FALSE;

begin
    UUT: ERROR_UNIT
    port map (
        data_in => data_in,
        data_out => data_out,
        taps_in => taps_in,
        taps => taps,
        error_out => error_out,
        d => d
    );

    process
    begin
        data_out <= (p2 - x"0010", p2 + x"0008");
        wait for 10 ns;
        wait for 500 ns;
        END_SIM <= TRUE;
        wait;
    end process;
end ERROR_UNIT_TB_ARCH;

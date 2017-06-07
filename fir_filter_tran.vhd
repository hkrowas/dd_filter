----------------------------------------------------------------------------
--
--  Transverse FIR filter
--
--  This is an implementation of a transverse FIR filter. It has less logic
--  depth than an ordinary FIR filter.
--
--  Revision History:
--      2017-06-05   Harrison Krowas   Initial Revision
----------------------------------------------------------------------------

--  FIR_FILTER_TRAN
--
--  Inputs:
--      clock
--      data_in -  Input data to filter. New data should be given on every clock
--      taps_reset     -  Taps take these values when reset
--      taps_in        -  Taps take these values on every colck
--      reset          -  Sets tap values to taps_reset
--
--  Outputs:
--      taps         -  Value of taps
--      ein          -  Current input on delay line of the filter
--      data_out     -  Output data from filter.
--
--  Generic:
--      n_taps   -  Number of taps

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.tap_array.all;

entity FIR_FILTER_TRAN is
    generic (
        n_taps  :  integer := 16
    );
    port (
        clock      :  in  std_logic;
        data_in    :  in  com;
        taps_reset :  in  tap_array(0 to n_taps - 1);
        taps_in    :  in  tap_array(0 to n_taps - 1);
        reset      :  in  std_logic;
        ein        :  buffer tap_array(0 to n_taps - 1) :=
        ((x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
       , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
       , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
       , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"));
        taps       :  buffer tap_array(0 to n_taps - 1) :=
        ((x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
       , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
       , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
       , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"));
        data_out   :  buffer com
    );
end FIR_FILTER_TRAN;

architecture FIR_FILTER_TRAN_ARCH of FIR_FILTER_TRAN is
    signal products : tap_array(0 to n_taps - 1);
    signal sums : tap_array(0 to n_taps - 1);
    signal sums_buf : tap_array(0 to n_taps - 1);
    component MAC
        port (
            z     : in com;
            w     : in com;
            a     : in com;
            result     : out com
        );
    end component;
begin
    FIRST_MAC : MAC
    port map (
        z => ein(0),
        w => taps(n_taps - 1),
        a => (x"0000", x"0000"),
        result => sums(n_taps - 1)
    );
    -- Multiplier array generate
    REST_MAC : for i in 1 to n_taps - 1 generate
    begin
        MACs : MAC
        port map (
            z => ein(0),
            w => taps(n_taps - 1 - i),
            a => sums_buf(n_taps - i),
            result => sums(n_taps - 1 - i)
        );
    end generate;
    data_out <= sums(0);
    process (clock)
    begin
        if (rising_edge(clock)) then
            -- Delay line
            ein(0) <= data_in;
            for i in 1 to n_taps - 1 loop
                ein(i) <= ein(i - 1);
            end loop;
            for i in 0 to n_taps - 1 loop
                sums_buf(i) <= sums(i);
            end loop;
            taps <= taps_in;
            -- Taps update
            if (reset = '1') then
                taps <= taps_reset;
                taps(6)(0) <= x"F000";
                taps(7)(0) <= x"7000";
                taps(8)(0) <= x"F000";
                for i in 1 to n_taps - 1 loop
                    ein(i)(0) <= x"0000";
                    ein(i)(1) <= x"0000";
                end loop;
            end if;
        end if;
    end process;
end FIR_FILTER_TRAN_ARCH;

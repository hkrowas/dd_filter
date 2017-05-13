----------------------------------------------------------------------------
--
--  FIR filter
--
--  This is an implementation of an FIR filter.
--
--  Revision History:
--      2017-04-11   Harrison Krowas   Initial Revision
----------------------------------------------------------------------------

--  FIR_FILTER
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

entity FIR_FILTER is
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
        ((x"7EFF", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
       , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
       , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
       , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"));
        data_out   :  buffer com
    );
end FIR_FILTER;

architecture FIR_FILTER_ARCH of FIR_FILTER is
    signal products : tap_array(0 to n_taps - 1);
    signal sums : tap_array(0 to n_taps - 1);
    component COM_MUL_ARRAY
        generic (
            n  :  integer := 16
        );
        port (
            z  :  in  com;
            w  :  in  com;
            c  :  out com
        );
    end component;
begin
    -- Multiplier array generate
    MUL_TAP_ARRAY : for i in 0 to n_taps - 1 generate
    begin
        MULS : COM_MUL_ARRAY
        port map (
            z => ein(i),
            w => taps(i),
            c => products(i)
        );
    end generate;
    sums(0)(0) <= products(0)(0);
    sums(0)(1) <= products(0)(1);
    SUM_ARRAY : for i in 1 to n_taps - 1 generate
    begin
        sums(i)(0) <= sums(i - 1)(0) + products(i)(0);
        sums(i)(1) <= sums(i - 1)(1) + products(i)(1);
    end generate;
    data_out <= sums(n_taps - 1);
    process (clock)
    begin
        if (rising_edge(clock)) then
            -- Delay line
            ein(0) <= data_in;
            for i in 1 to n_taps - 1 loop
                ein(i) <= ein(i - 1);
            end loop;
            taps <= taps_in;
            -- Taps update
            if (reset = '1') then
                taps <= taps_reset;
                taps(0)(0) <= x"7EFF";
                for i in 1 to n_taps - 1 loop
                    ein(i)(0) <= x"0000";
                    ein(i)(1) <= x"0000";
                end loop;
            end if;
        end if;
    end process;
end FIR_FILTER_ARCH;

----------------------------------------------------------------------------
--
--  Decision-Directed LMS Error Adaptive FIR Filter
--
--  This is the complete entity declaration adaptive filter.
--
--  Revision History:
--      2017-04-11   Harrison Krowas   Initial Revision
----------------------------------------------------------------------------

--  DD_FILTER
--
--  Inputs:
--      clock
--      data_in -  Input data to filter. New data should be given on every clock
--      taps_reset     -  Initial tap values
--      reset          -  Sets tap values to taps input
--
--  Outputs:
--      data_out     -  Output data from filter.
--      error_out    -  Computed error signal. Used for testing purposes.
--
--  Generic:
--      n_taps   -  Number of taps

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

use work.tap_array.all;

entity DD_FILTER is
    generic (
        n_taps  :  integer := 16
    );
    port (
        clock      :  in  std_logic;
        data_in    :  in  com;
        taps_reset :  in  tap_array(0 to n_taps - 1);
        reset      :  in  std_logic;
        data_out   :  buffer com;
        error_out  :  out std_logic_vector(15 downto 0)
    );
end DD_FILTER;

architecture DD_FILTER_ARCH of DD_FILTER is
    component FIR_FILTER_TRAN
        generic (
            n_taps  :  integer := 16
        );
        port (
            clock      :  in  std_logic;
            data_in    :  in  com;
            taps_reset :  in  tap_array(0 to n_taps - 1);
            taps_in    :  in  tap_array(0 to n_taps - 1);
            reset      :  in  std_logic;
            ein        :  buffer tap_array(0 to n_taps - 1);
            taps       :  buffer tap_array(0 to n_taps - 1);
            data_out   :  buffer com
        );
    end component;
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
    signal taps_in     :  tap_array(0 to n_taps - 1);
    signal taps_error  :  tap_array(0 to n_taps - 1);
    signal taps        :  tap_array(0 to n_taps - 1);
    signal ein         :  tap_array(0 to n_taps - 1);
begin
    filter  :  FIR_FILTER_TRAN
        generic map (
            n_taps => n_taps
        )
        port map (
            clock      => clock,
            data_in    => data_in,
            taps_reset => taps_reset,
            taps_in    => taps_in,
            reset      => reset,
            ein        => ein,
            taps       => taps,
            data_out   => data_out
        );
    error  :  ERROR_UNIT
        generic map (
            n_taps => n_taps
        )
        port map (
            data_in    => ein,
            data_out   => data_out,
            taps_in    => taps,
            taps       => taps_in
            --error_out  => error_out
        );
end DD_FILTER_ARCH;

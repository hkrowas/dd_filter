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
        data_in    :  in  std_logic_vector(15 downto 0);
        taps_reset :  in  tap_array(0 to n_taps - 1);
        reset      :  in  std_logic;
        data_out   :  buffer std_logic_vector(15 downto 0);
        error_out  :  out std_logic_vector(15 downto 0)
    );
end DD_FILTER;

architecture DD_FILTER_ARCH of DD_FILTER is
    component FIR_FILTER
        port (
            clock      :  in  std_logic;
            reset      :  in  std_logic;
            taps_error :  in  tap_array(0 to n_taps - 1);
            taps_reset :  in  tap_array(0 to n_taps - 1);
            data_in    :  in  std_logic_vector(15 downto 0);
            taps       :  out tap_array(0 to n_taps - 1);
            data_out   :  buffer std_logic_vector(15 downto 0)
        );
    end component;

    component ERROR_UNIT
        port (
            data_in    :  in  std_logic_vector(15 downto 0);
            data_out   :  in  std_logic_vector(15 downto 0);
            taps       :  in  tap_array(0 to n_taps - 1);
            taps_error :  out tap_array(0 to n_taps - 1);
            error_out  :  out std_logic_vector(15 downto 0)
        );
    end component;

    signal taps_error  :  tap_array(0 to n_taps - 1);
    signal taps        :  tap_array(0 to n_taps - 1);
begin
    filter  :  FIR_FILTER
        port map (
            clock      => clock,
            reset      => reset,
            taps_error => taps_error,
            taps_reset => taps_reset,
            data_in    => data_in,
            taps       => taps,
            data_out   => data_out
        );
    error  :  ERROR_UNIT
        port map (
            data_in    => data_in,
            data_out   => data_out,
            taps       => taps,
            taps_error => taps_error,
            error_out  => error_out
        );
end DD_FILTER_ARCH;

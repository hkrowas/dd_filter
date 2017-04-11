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
--      data_out     -  Output data from filter.
--
--  Generic:
--      n_taps   -  Number of taps

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

use work.tap_array.all;

entity FIR_FILTER is
    generic (
        n_taps  :  integer := 16
    );
    port (
        clock      :  in  std_logic;
        data_in    :  in  std_logic_vector(15 downto 0);
        taps_reset :  in  tap_array(0 to n_taps - 1);
        taps_in    :  in  tap_array(0 to n_taps - 1);
        reset      :  in  std_logic;
        taps       :  out tap_array(0 to n_taps - 1);
        data_out   :  buffer std_logic_vector(15 downto 0)
    );
end FIR_FILTER;

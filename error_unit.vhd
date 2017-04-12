----------------------------------------------------------------------------
--
--  Error Unit
--
--  This is an implementation of the error unit for the DD_FILTER.
--
--  On every clock, the error unit computes the LMS error of the output data with
--  the closest point on the 16-QAM constellation. It computes the new values of
--  the taps based on the old values and outputs them to the FIR filter.
--
--  Revision History:
--      2017-04-11   Harrison Krowas   Initial Revision
----------------------------------------------------------------------------

--  ERROR_UNIT
--
--  Inputs:
--      data_in   -  Input data to the filter. Needed to compute new tap values.
--      data_out  -  Output data from the filter.
--      taps      -  Current value of filter taps.
--
--  Outputs:
--      taps_error   -  New value of taps based on error.
--      error_out    -  Computed error signal. Used for testing purposes.
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
        data_in    :  in  std_logic_vector(15 downto 0);
        data_out   :  in  std_logic_vector(15 downto 0);
        taps       :  out tap_array(0 to n_taps - 1);
        taps_error :  out tap_array(0 to n_taps - 1);
        error_out  :  out std_logic_vector(15 downto 0)
    );
end FIR_FILTER;

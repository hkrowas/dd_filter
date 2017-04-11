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
--      data_in  -  Input data to filter. New data should be given on every clock
--      taps     -  Initial tap values
--      reset    -  Sets tap values to taps input
--
--  Outputs:
--      data_out -  Output data from filter.
--      error_out    -  Computed error signal
--
--  Generic:
--      n_taps   -  Number of taps

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

package tap_array is
    type  tap_array is array(integer range <>) of std_logic_vector(15 downto 0);
end tap_array;

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
        clock    :  in  std_logic;
        data_in  :  in  std_logic_vector(15 downto 0);
        taps     :  in  tap_array(0 to n_taps - 1);
        reset    :  in  std_logic;
        data_out :  out std_logic_vector(15 downto 0);
        error_out:  out std_logic_vector(15 downto 0)
    );


end DD_FILTER;

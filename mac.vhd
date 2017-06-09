----------------------------------------------------------------------------
--
--  MAC
--
--  This is an implementation of a MAC unit. It does not contain a register that
--  saves the result; it is entirely combinational.
--
--  Revision History:
--      2017-06-05   Harrison Krowas   Initial Revision
----------------------------------------------------------------------------

--  MAC
--
--  Inputs:
--      clock
--      a       -  First operand of multiplication
--      b       -  Second operand of multiplication
--      x       -  Addition operand
--
--  Outputs:
--      c       -  MAC output
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.tap_array.all;


entity MAC is
    port (
        z     : in com;
        w     : in com;
        a     : in com;
        result     : out com
    );
end MAC;

architecture MAC_ARCH of MAC is
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
    signal c : com;
begin
    MULTIPLIER : COM_MUL_ARRAY
    port map (
        z => z,
        w => w,
        c => c
    );
    result(0) <= c(0) + a(0);
    result(1) <= c(1) + a(1);
end MAC_ARCH;

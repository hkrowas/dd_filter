library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

package tap_array is
    type  com is array(0 to 1) of std_logic_vector(15 downto 0);
    type  tap_array is array(integer range <>) of com;
    type  constellation_array is array(0 to 15) of com;
    constant QAM16 : constellation  :=
        ((x"C000", x"4000"), (x"A000", x"4000"), (x"2000", x"4000"), (x"4000", x"4000"),
         (x"C000", x"2000"), (x"A000", x"2000"), (x"2000", x"2000"), (x"4000", x"2000"),
         (x"C000", x"A000"), (x"A000", x"A000"), (x"2000", x"A000"), (x"4000", x"A000"),
         (x"C000", x"C000"), (x"A000", x"C000"), (x"2000", x"C000"), (x"4000", x"C000"));
end tap_array;

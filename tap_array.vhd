library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

package tap_array is
    type  tap_array is array(integer range <>) of std_logic_vector(15 downto 0);
    type  com is array(0 to 1) of std_logic_vector(15 downto 0);
end tap_array;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

package tap_array is
    type  com is array(0 to 1) of std_logic_vector(15 downto 0);
    type  tap_array is array(integer range <>) of com;
    type  constellation_array is array(0 to 15) of com;
    constant p1  :  std_logic_vector(15 downto 0) := x"1000";
    constant p2  :  std_logic_vector(15 downto 0) := x"3000";
    constant p2_p1 : std_logic_vector(15 downto 0) := p2 + p1;
    constant p2_p1_d_2 : std_logic_vector(15 downto 0) := '0' & p2_p1(15 downto 1);
    constant m1  :  std_logic_vector(15 downto 0) := '1' & p1(14 downto 0);
    constant m2  :  std_logic_vector(15 downto 0) := '1' & p2(14 downto 0);
    -- 16QAM constellation used:
    --  2  6  14  10
    --  3  7  15  11
    --  1  5  13  9
    --  0  4  12  8
    constant QAM16 : constellation_array  :=
        ((m2, m2), (m2, m1), (m2, p2), (m2, p1)
       , (m1, m2), (m1, m1), (m1, p2), (m1, p1)
       , (p2, m2), (p2, m1), (p2, p2), (p2, p1)
       , (p1, m2), (p1, m1), (p1, p2), (p1, p1));
end tap_array;

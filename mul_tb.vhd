----------------------------------------------------------------------------
--
--  Array Multiplier Test Bench
--
--  This is the test bernch for an array multiplier (mul.vhd)
--
--  Revision History:
--     2017-04-19  Harrison Krowas     Initial revision.
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity MUL_TB is
end MUL_TB;

architecture MUL_TB_ARCH of MUL_TB is
    component MUL_ARRAY
    generic (
        n  :  integer := 16
    );
    port (
        x  :  in  std_logic_vector(n - 1 downto 0);
        y  :  in  std_logic_vector(n - 1 downto 0);
        z  :  out std_logic_vector(2 * n - 1 downto 0)
    );
    end component;

    signal x  :  std_logic_vector(15 downto 0);
    signal y  :  std_logic_vector(15 downto 0);
    signal z  :  std_logic_vector(31 downto 0);

    type in_type is array(0 to 9) of std_logic_vector(15 downto 0);

    -- The two summands
    signal a : in_type := (x"0002", x"0000", x"FFFF", x"1111", x"1111", x"EBA3"
                         , x"0310", x"4420", x"5843", x"FCDA");
    signal b : in_type := (x"0003", x"0000", x"FFFF", x"1111", x"320E", x"F309"
                         , x"52B0", x"5DEF", x"DE82", x"FF00");

begin
    UUT: MUL_ARRAY
    port map (
        x => x,
        y => y,
        z => z
    );
    process
    begin
        for i in in_type'range loop
            x <= a(i);
            y <= b(i);
            wait for 1 ns;
            assert(std_match(z, std_logic_vector(unsigned(a(i)) * unsigned(b(i)))));
            wait for 10 ns;
        end loop;
        wait;
    end process;
end MUL_TB_ARCH;

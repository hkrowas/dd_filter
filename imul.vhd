----------------------------------------------------------------------------
--
--  Signed Array Multiplier
--
--  This is an implementation of a signed array multiplier. It is entirely
--  combinational. It uses the approach described in
--  https://en.wikipedia.org/wiki/Binary_multiplier, which minimizes the logic
--  needed.
--
--  Revision History:
--      2017-05-14   Harrison Krowas   Initial Revision
----------------------------------------------------------------------------

--  IMUL_ARRAY
--
--  Inputs:
--      x  -  First multiplicand
--      y  -  Second multiplicand
--
--  Outputs:
--      z  -  Product
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

use work.tap_array.all;

entity IMUL_ARRAY is
    generic (
        n  :  integer := 16
    );
    port (
        x  :  in  std_logic_vector(n - 1 downto 0);
        y  :  in  std_logic_vector(n - 1 downto 0);
        z  :  out std_logic_vector(2 * n - 1 downto 0)
    );
end IMUL_ARRAY;

architecture IMUL_ARRAY_ARCH of IMUL_ARRAY is
    component FullAdder
        port (
            A, B  :  in   std_logic;       --  addends
            Cin   :  in   std_logic;       --  carry in input
            Sum   :  out  std_logic;      --  sum output
            Cout  :  out  std_logic       --  carry out output
        );
    end component;
    type std_array is array (0 to n - 1) of std_logic;
    type mul_array is array (0 to n - 2) of std_array;
    signal a  :  mul_array;     -- Summand coming into each adder
    signal b  :  mul_array;     -- Summand coming into each adder
    signal c  : mul_array;      -- Sum coming out of each adder
    signal cout : mul_array;
begin
    -- Generate rows
    ROWS : for i in 0 to n - 2 generate
    begin
        -- Generate columns
        COLUMNS : for j in 0 to n - 1 generate
        begin
            b(i)(j) <= x(j) and y(i + 1);
            FIRST_ROW : if i = 0 generate
            begin
                FIRST_ROW_FIRST_COLUMN : if j = 0 generate
                begin
                    a(i)(j) <= x(j) and y(i);
                    U1 : Fulladder
                    port map (
                        A => a(i)(j + 1),
                        B => b(i)(j),
                        Cin => '0',
                        Sum => c(i)(j),
                        Cout => cout(i)(j)
                    );
                end generate;
                FIRST_ROW_REST_COLUMNS : if j > 0 and j < n - 1 generate
                begin
                    a(i)(j) <= x(j) and y(i);
                    U2 : FullAdder
                    port map (
                        A => a(i)(j + 1),
                        B => b(i)(j),
                        Cin => cout(i)(j - 1),
                        Sum => c(i)(j),
                        Cout => cout(i)(j)
                    );
                end generate;
                FIRST_ROW_LAST_COLUMN : if j = n - 1 generate
                begin
                    a(i)(j) <= not(x(j) and y(i));
                    U3 : FullAdder
                    port map (
                        A => '1',
                        B => "not"(b(i)(j)),
                        Cin => cout(i)(j - 1),
                        Sum => c(i)(j),
                        Cout => cout(i)(j)
                    );
                end generate;
            end generate;
            MIDDLE_ROWS : if i > 0 and i < n - 2 generate
            begin
                a(i)(j) <= c(i - 1)(j);
                FIRST_COLUMN : if j = 0 generate
                begin
                    U4 : FullAdder
                    port map (
                        A => a(i)(j + 1),
                        B => b(i)(j),
                        Cin => '0',
                        Sum => c(i)(j),
                        Cout => cout(i)(j)
                    );
                end generate;
                REST_COLUMNS : if j > 0 and j < n - 1 generate
                begin
                    U5 : FullAdder
                    port map (
                        A => a(i)(j + 1),
                        B => b(i)(j),
                        Cin => cout(i)(j - 1),
                        Sum => c(i)(j),
                        Cout => cout(i)(j)
                    );
                end generate;
                LAST_COLUMN : if j = n - 1 generate
                begin
                    U6 : FullAdder
                    port map (
                        A => cout(i - 1)(j),
                        B => "not"(b(i)(j)),
                        Cin => cout(i)(j - 1),
                        Sum => c(i)(j),
                        Cout => cout(i)(j)
                    );
                end generate;
            end generate;
            LAST_ROW : if i = n - 2 generate
            begin
                a(i)(j) <= c(i - 1)(j);
                FIRST_COLUMN : if j = 0 generate
                begin
                    U7 : FullAdder
                    port map (
                        A => a(i)(j + 1),
                        B => "not"(b(i)(j)),
                        Cin => '0',
                        Sum => c(i)(j),
                        Cout => cout(i)(j)
                    );
                end generate;
                REST_COLUMNS : if j > 0 and j < n - 1 generate
                begin
                    U8 : FullAdder
                    port map (
                        A => a(i)(j + 1),
                        B => "not"(b(i)(j)),
                        Cin => cout(i)(j - 1),
                        Sum => c(i)(j),
                        Cout => cout(i)(j)
                    );
                end generate;
                LAST_COLUMN : if j = n - 1 generate
                begin
                    U9 : FullAdder
                    port map (
                        A => cout(i - 1)(j),
                        B => b(i)(j),
                        Cin => cout(i)(j - 1),
                        Sum => c(i)(j),
                        Cout => cout(i)(j)
                    );
                end generate;
            end generate;
        end generate;
    end generate;
    -- Denote outputs
    OUTPUTS : for i in 0 to 2 * n - 1 generate
    begin
        FIRST_OUT : if i = 0 generate
        begin
            z(i) <= a(i)(0);
        end generate;
        EDGES : if i > 0 and i < n generate
        begin
            z(i) <= c(i - 1)(0);
        end generate;
        LAST_ROW_OUT : if i > n - 1 and i < 2 * n - 1 generate
        begin
            z(i) <= c(n - 2)(i - (n - 1));
        end generate;
        LAST_OUT : if i = 2 * n - 1 generate
        begin
            z(i) <= "not"(cout(n - 2)(n - 1));
        end generate;
    end generate;
end IMUL_ARRAY_ARCH;

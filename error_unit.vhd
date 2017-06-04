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
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.tap_array.all;

entity ERROR_UNIT is
    generic (
        n_taps  :  integer := 16
    );
    port (
        data_in    :  in  tap_array(0 to n_taps - 1);
        data_out   :  in  com;
        taps_in    :  in  tap_array(0 to n_taps - 1);
        taps       :  out tap_array(0 to n_taps - 1);
        error_out  :  out com;
        d          :  out com
    );
end ERROR_UNIT;

architecture ERROR_UNIT_ARCH of ERROR_UNIT is
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
    component IMUL_ARRAY
        generic (
            n  :  integer := 16
        );
        port (
            x  :  in  std_logic_vector(n - 1 downto 0);
            y  :  in  std_logic_vector(n - 1 downto 0);
            z  :  out std_logic_vector(2 * n - 1 downto 0)
        );
    end component;
    component Adder
        generic (
            bitsize : integer := 16      -- default width is 8-bits
        );
        port (
            X, Y :  in  std_logic_vector((bitsize - 1) downto 0);     -- addends
            Ci   :  in  std_logic;                                    -- carry in
            S    :  out  std_logic_vector((bitsize - 1) downto 0);    -- sum out
            Cout_m1 : out std_logic;
            Co   :  out  std_logic                                    -- carry out
        );
    end component;
    signal const_i : std_logic_vector(3 downto 0);
    signal bot : std_logic_vector(15 downto 0);
    signal left : std_logic_vector(15 downto 0);
    signal e : com;
    signal mu : std_logic_vector(15 downto 0) := x"0800";
    signal mu_e : com;
    signal mu_e_0_32 : std_logic_vector(31 downto 0);
    signal mu_e_1_32 : std_logic_vector(31 downto 0);
    signal mu_e_in : tap_array(0 to n_taps - 1);
    signal data_in_mul : tap_array(0 to n_taps - 1);
    signal e0 : std_logic_vector(15 downto 0);
    signal e1 : std_logic_vector(15 downto 0);
    signal taps_s  :  tap_array(0 to n_taps - 1);
    type     cout_array  is array(0 to n_taps - 1) of std_logic_vector(0 to 1);
    signal   cout_m1  : cout_array;
    signal   cout     :  cout_array;
    type     overflow_inner is array(0 to 1) of std_logic_vector(1 downto 0);
    type     overflow_array is array(0 to n_taps - 1) of overflow_inner;
    signal   overflow  : overflow_array;
begin
    -- Use sign of real and imaginary parts of data_out to determine quadrant.
    const_i(3) <= not(data_out(0)(15));
    const_i(1) <= not(data_out(1)(15));
    -- Find whether data_out is in bottom and left of the quadrant.
    with data_out(1)(15) select
    bot <= data_out(1) - p2_p1_d_2          when '0',
           not(data_out(1)) + 1 - p2_p1_d_2 when others;
    with data_out(0)(15) select
    left <= data_out(0) - p2_p1_d_2          when '0',
            not(data_out(0)) + 1 - p2_p1_d_2 when others;
    const_i(2) <= left(15);
    const_i(0) <= bot(15);
    e(0) <= QAM16(to_integer(unsigned(const_i)))(0) - data_out(0);
    e(1) <= QAM16(to_integer(unsigned(const_i)))(1) - data_out(1);
    e0 <= QAM16(to_integer(unsigned(const_i)))(0) - data_out(0);
    e1 <= QAM16(to_integer(unsigned(const_i)))(1) - data_out(1);
    d(0) <= QAM16(to_integer(unsigned(const_i)))(0);
    d(1) <= QAM16(to_integer(unsigned(const_i)))(1);
    -- Calculate error
    E_R_MUL : IMUL_ARRAY
    port map (
        x => e(0),
        y => mu,
        z => mu_e_0_32
    );
    E_I_MUL : IMUL_ARRAY
    port map (
        x => e(1),
        y => mu,
        z => mu_e_1_32
    );
    mu_e(0) <= mu_e_0_32(30 downto 15);
    mu_e(1) <= mu_e_1_32(30 downto 15);
    MU_E_IN_MUL_generate : for i in 0 to n_taps - 1 generate
        -- Take complex conjugate of Ein.
        data_in_mul(i)(0) <= data_in(i)(0);
        data_in_mul(i)(1) <= not(data_in(i)(1)) + 1;
        MU_E_IN_MUL : COM_MUL_ARRAY
        port map (
            z => mu_e,
            w => data_in_mul(i),
            c => mu_e_in(i)
        );
    end generate;
    NEW_TAPS: for i in 0 to n_taps - 1 generate
        REAL_ADDER : Adder
        port map (
            X => taps_in(i)(0),
            Y => mu_e_in(i)(0),
            Ci => '0',
            S => taps_s(i)(0),
            Cout_m1 => cout_m1(i)(0),
            Co      => cout(i)(0)
        );
        C_ADDER : Adder
        port map (
            X => taps_in(i)(1),
            Y => mu_e_in(i)(1),
            Ci => '0',
            S => taps_s(i)(1),
            Cout_m1 => cout_m1(i)(1),
            Co      => cout(i)(1)
        );
        overflow(i)(0) <= (cout_m1(i)(0) xor cout(i)(0)) & taps_in(i)(0)(15);
        overflow(i)(1) <= (cout_m1(i)(1) xor cout(i)(1)) & taps_in(i)(1)(15);
        -- Need to prevent overflow
        -- Real
        taps(i)(0) <= x"7FFF" when(std_match(overflow(i)(0), "10")) else
                      x"8000" when(std_match(overflow(i)(0), "11")) else
                      taps_s(i)(0);
        taps(i)(1) <= x"7FFF" when(std_match(overflow(i)(1), "10")) else
                      x"8000" when(std_match(overflow(i)(1), "11")) else
                      taps_s(i)(1);
    end generate;
    error_out <= e;
end ERROR_UNIT_ARCH;

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
        taps_error :  out tap_array(0 to n_taps - 1);
        error_out  :  out std_logic_vector(15 downto 0)
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
    signal const_i : std_logic_vector(3 downto 0);
    signal bot : std_logic_vector(15 downto 0);
    signal left : std_logic_vector(15 downto 0);
    signal e : com;
    signal mu : std_logic_vector(15 downto 0) := x"0010";
    signal mu_e : com;
    signal mu_e_in : tap_array(0 to n_taps - 1);
    signal data_in_mul : tap_array(0 to n_taps - 1);
begin
    -- Use sign of real and imaginary parts of data_out to determine quadrant.
    const_i(3) <= not(data_out(0)(15));
    const_i(1) <= not(data_out(1)(15));
    -- Find whether data_out is in bottom and left of the quadrant.
    bot <= ('0' & data_out(1)(14 downto 0)) - p2_p1_d_2;
    left <= ('0' & data_out(0)(14 downto 0)) - p2_p1_d_2;
    const_i(2) <= left(15);
    const_i(0) <= bot(15);
    e(0) <= QAM16(to_integer(unsigned(const_i)))(0) - data_out(0);
    e(1) <= QAM16(to_integer(unsigned(const_i)))(1) - data_out(1);
    -- Calculate error
    E_R_MUL : MUL_ARRAY
    port map (
        x => e(0),
        y => mu,
        z(30 downto 15) => mu_e(0)
    );
    E_I_MUL : MUL_ARRAY
    port map (
        x => e(1),
        y => mu,
        z(30 downto 15) => mu_e(1)
    );
    MU_E_IN_MUL_generate : for i in 0 to n_taps - 1 generate
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
        taps(i)(0) <= taps_in(i)(0) + mu_e_in(i)(0);
        taps(i)(1) <= taps_in(i)(1) + mu_e_in(i)(1);
    end generate;
end ERROR_UNIT_ARCH;

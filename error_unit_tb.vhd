----------------------------------------------------------------------------
--
--  ERROR_UNIT Test Bench
--
--  This is the test bernch for the error unit of the DD filter (error_unit.vhd)
--  It tests the updated tap coefficients for one set of inputs, and the last
--  tap coefficient is set to result in an overflow.
--
--  Revision History:
--     2017-05-05  Harrison Krowas     Initial revision.
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.tap_array.all;

entity ERROR_UNIT_TB is
end ERROR_UNIT_TB;

architecture ERROR_UNIT_TB_ARCH of ERROR_UNIT_TB is
    component ERROR_UNIT
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
    end component;
    signal n_taps : integer := 16;
    signal data_in : tap_array(0 to n_taps - 1) :=
     ((x"0011", x"0100"), (x"01A0", x"0010"), (x"00FF", x"00EF"), (x"0000", x"0000")
    , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
    , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"01FF", x"170F")
    , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"30EE", x"3EFF"));
    signal data_out : com;
    signal taps_in : tap_array(0 to n_taps - 1) :=
    ((x"2222", x"423B"), (x"0100", x"0010"), (x"00DD", x"80E0"), (x"0000", x"0000")
   , (x"0000", x"0000"), (x"0230", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
   , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"003D", x"02EF")
   , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"7FFE", x"8001"));
   signal taps  :  tap_array(0 to n_taps - 1);
   signal error_out  :  com;
   signal d : com;
   signal mu : com := (x"0800", x"0000");
   --signal taps : tap_array(0 to n_taps -1) :=
   signal END_SIM : BOOLEAN := FALSE;
   constant real_error : std_logic_vector(15 downto 0) := x"0310";
   constant im_error   : std_logic_vector(15 downto 0) := x"0308";
   signal e  :  com;
   signal mu_e : com;
   signal mu_e_in : com;
   signal data_in_conj : com;
   function com_mul_fun(w : com; z : com)
                   return com is
       variable xu_32  :  std_logic_vector(31 downto 0);
       variable yv_32  :  std_logic_vector(31 downto 0);
       variable yu_32  :  std_logic_vector(31 downto 0);
       variable xv_32  :  std_logic_vector(31 downto 0);
       variable xu     :  std_logic_vector(15 downto 0);
       variable yv     :  std_logic_vector(15 downto 0);
       variable xv     :  std_logic_vector(15 downto 0);
       variable yu     :  std_logic_vector(15 downto 0);
       variable c      :  com;
    begin
       xu_32 := std_logic_vector(signed(w(0)) * signed(z(0)));
       yv_32 := std_logic_vector(signed(w(1)) * signed(z(1)));
       yu_32 := std_logic_vector(signed(w(1)) * signed(z(0)));
       xv_32 := std_logic_vector(signed(w(0)) * signed(z(1)));
       xu := xu_32(30 downto 15);
       yv := yv_32(30 downto 15);
       yu := yu_32(30 downto 15);
       xv := xv_32(30 downto 15);
       c(0) := xu - yv;
       c(1) := yu + xv;
       return(c);
   end com_mul_fun;
begin
    UUT: ERROR_UNIT
    port map (
        data_in => data_in,
        data_out => data_out,
        taps_in => taps_in,
        taps => taps,
        error_out => error_out,
        d => d
    );
    process
    begin
        -- Calculate expected error
        data_out <= (p2 - real_error, p2 - im_error);
        e <= (real_error, im_error);
        wait for 10 ns;
        -- Assert error and decision are working
        assert(std_match(error_out(0), real_error));
        assert(std_match(error_out(1), im_error));
        assert(std_match(d(0), p2));
        assert(std_match(d(1), p2));
        mu_e <= com_mul_fun(mu, e);
        -- Loop through all taps
        for i in 0 to n_taps - 1 loop
            data_in_conj(0) <= data_in(i)(0);
            data_in_conj(1) <= std_logic_vector(0 - signed(data_in(i)(1)));
            wait for 1 ns;
            mu_e_in <= com_mul_fun(mu_e, data_in_conj);
            wait for 1 ns;
            -- Test overflow on last tap. Inputs for last tap are designed to overflow
            if i = 15 then
                assert(std_match(taps(i)(0), x"7FFF"));
                assert(std_match(taps(i)(1), x"8000"));
            else
                assert(std_match(taps_in(i)(0) + mu_e_in(0), taps(i)(0)));
                assert(std_match(taps_in(i)(1) + mu_e_in(1), taps(i)(1)));
            end if;
        end loop;
        END_SIM <= TRUE;
        wait;
    end process;
end ERROR_UNIT_TB_ARCH;

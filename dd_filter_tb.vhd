----------------------------------------------------------------------------
--
--  DD_FILTER Test Bench
--
--  This is the test bernch for the complete Decision Directed Filter.
--
--  Revision History:
--      2017-05-06   Harrison Krowas   Initial Revision
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

use std.textio.all;

use work.tap_array.all;

entity DD_FILTER_TB is
end DD_FILTER_TB;

architecture DD_FILTER_TB_ARCH of DD_FILTER_TB is
    component DD_FILTER
        generic (
            n_taps  :  integer := 16
        );
        port (
            clock      :  in  std_logic;
            data_in    :  in  com;
            taps_reset :  in  tap_array(0 to n_taps - 1);
            reset      :  in  std_logic;
            data_out   :  buffer com;
            error_out  :  out std_logic_vector(15 downto 0)
        );
    end component;
    signal n_taps : integer := 16;
    signal N : integer := 1000;
    type data_array is array(0 to N - 1) of com;
    signal data_in  :  data_array;
    signal data_out :  data_array;
    signal dd_in    :  com;
    signal dd_out   :  com;
    signal SPACE    :  string(1 to 1) := " ";
    signal END_SIM  :  BOOLEAN := FALSE;
    signal clock    :  std_logic := '0';
    signal taps_reset : tap_array(0 to n_taps - 1) :=
    ((x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
   , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
   , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
   , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000"));
   signal dd_in0 : std_logic_vector(15 downto 0);
   signal dd_in1 : std_logic_vector(15 downto 0);
   signal data_out0 : std_logic_vector(15 downto 0);
   signal data_out1 : std_logic_vector(15 downto 0);
   signal reset : std_logic;
begin
    UUT : DD_FILTER
    port map (
        clock => clock,
        data_in => dd_in,
        taps_reset => taps_reset,
        reset => reset,
        data_out => dd_out
    );

    process
        file data_in_file : text;
        file data_out_file : text;
        variable data_in_line : line;
        variable data_out_line : line;
        variable test_var : std_logic_vector(15 downto 0);
    begin
        file_open(data_in_file, "input", read_mode);
        file_open(data_out_file, "output", write_mode);
        -- Read in data
        readline(data_in_file, data_in_line);
        for i in 0 to N - 1 loop
            read(data_in_line, test_var);
            data_in(i)(0) <= test_var;
            read(data_in_line, test_var);
            data_in(i)(1) <= test_var;
        end loop;
        wait for 1 ns;
        dd_in(0) <= data_in(1)(0);
        dd_in(1) <= data_in(1)(1);
        dd_in0 <= data_in(1)(0);
        dd_in1 <= data_in(1)(1);
        reset <= '1';
        wait for 400 ns;
        reset <= '0';
        for i in 0 to N - 1 loop
            dd_in(0) <= data_in(i)(0);
            dd_in(1) <= data_in(i)(1);
            dd_in0 <= data_in(i)(0);
            dd_in1 <= data_in(i)(1);
            wait for 20 ns;
            data_out(i)(0) <= dd_out(0);
            data_out(i)(1) <= dd_out(1);
            data_out0 <= dd_out(0);
            data_out1 <= dd_out(1);
        end loop;
        -- Write out output
        for i in 0 to N - 1 loop
            test_var := data_out(i)(0);
            write(data_out_line, test_var);
            write(data_out_line, SPACE);
            test_var := data_out(i)(1);
            write(data_out_line, test_var);
            write(data_out_line, SPACE);
        end loop;
        writeline(data_out_file, data_out_line);
        END_SIM <= TRUE;
        wait;
    end process;

    CLOCK_CLK : process

    begin
        -- this process generates a 20 ns period, 50% duty cycle clock
        -- only generate clock if still simulating
        if END_SIM = FALSE then
            clock <= '0';
            wait for 10 ns;
        else
            wait;
        end if;

        if END_SIM = FALSE then
            clock <= '1';
            wait for 10 ns;
        else
            wait;
        end if;

    end process;
end DD_FILTER_TB_ARCH;

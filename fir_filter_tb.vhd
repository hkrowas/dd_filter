----------------------------------------------------------------------------
--
--  FIR_FILTER Test Bench
--
--  This is the test bernch for an FIR filter (fir_filter.vhd)
--
--  Revision History:
--     2017-04-27  Harrison Krowas     Initial revision.
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.tap_array.all;


entity FIR_FILTER_TB is
end FIR_FILTER_TB;

architecture FIR_FILTER_TB_ARCH of FIR_FILTER_TB is
    component FIR_FILTER
        generic (
            n_taps  :  integer := 16
        );
        port (
            clock      :  in  std_logic;
            data_in    :  in  com;
            taps_reset :  in  tap_array(0 to n_taps - 1);
            taps_in    :  in  tap_array(0 to n_taps - 1);
            reset      :  in  std_logic;
            taps       :  buffer tap_array(0 to n_taps - 1);
            data_out   :  buffer com
        );
    end component;
    signal n_taps     : integer  := 16;
    signal clock      : std_logic;
    signal data_in    : com;
    signal taps_reset : tap_array(0 to n_taps - 1);
    signal taps_in    : tap_array(0 to n_taps - 1);
    signal reset      : std_logic;
    signal taps       : tap_array(0 to n_taps - 1);
    signal data_out   : com;

    signal data_out0  : std_logic_vector(15 downto 0);
    signal data_out1  : std_logic_vector(15 downto 0);

    type input_array is array(0 to 15) of com;

    signal input_data : input_array :=
        ((x"5220", x"0012"), (x"00AB", x"0001"), (x"0001", x"0000")
       , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
       , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
       , (x"5220", x"0012"), (x"00AB", x"0001"), (x"0001", x"0000")
       , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
       , (x"0000", x"0000"));

    signal out_value : com := ((x"0000"), (x"0000"));

    signal END_SIM : BOOLEAN := FALSE;

begin
    UUT: FIR_FILTER
    port map (
        clock => clock,
        data_in => data_in,
        taps_reset => taps_in,
        taps_in => taps_in,
        reset => '0',
        data_out => data_out
    );
    data_out0 <= data_out(0);
    data_out1 <= data_out(1);
    process
    begin
        taps_in <= ((x"0001", x"0000"), (x"0001", x"0000"), (x"0000", x"0000")
                  , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
                  , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
                  , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
                  , (x"0000", x"0000"), (x"0000", x"0000"), (x"0000", x"0000")
                  , (x"0000", x"0000"));
        for i in 0 to n_taps - 1 loop
            data_in <= input_data(i);
            wait for 20 ns;
        end loop;
        for i in 0 to 15 loop
            --out_value(0) <= std_logic_vector(
            --    unsigned(out_value(0))
            --    + (unsigned(input_data(0)(0)) * unsigned(taps_in(0)(0))
            --    - unsigned(input_data(0)(0)) * unsigned(taps_in(0)(0))));
            --out_value(1) <= std_logic_vector(
            --    unsigned(out_value(1))
            --    + (unsigned(input_data(0)(0)) * unsigned(taps_in(0)(0))
            --    + unsigned(input_data(0)(0)) * unsigned(taps_in(0)(0))));
        end loop;
        wait for 500 ns;
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
end FIR_FILTER_TB_ARCH;

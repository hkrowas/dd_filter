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
        ((x"0325", x"0012"), (x"00AB", x"0001"), (x"0001", x"0000")
       , (x"0000", x"0000"), (x"AAAA", x"0433"), (x"0353", x"F400")
       , (x"0FEE", x"0000"), (x"0021", x"0000"), (x"0000", x"0000")
       , (x"0123", x"0012"), (x"00AB", x"0001"), (x"0001", x"E0F9")
       , (x"0342", x"0000"), (x"FFFF", x"0000"), (x"0011", x"0000")
       , (x"0000", x"0000"));

    signal out_value : com := ((x"0000"), (x"0000"));
    signal im_value00 : std_logic_vector(31 downto 0);
    signal im_value01 : std_logic_vector(31 downto 0);
    signal im_value0_16 : std_logic_vector(15 downto 0);
    signal im_value1_16 : std_logic_vector(15 downto 0);
    signal out_value0 : std_logic_vector(15 downto 0);
    signal out_value1 : std_logic_vector(15 downto 0);
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
    out_value0 <= out_value(0);
    out_value1 <= out_value(1);
    process
    begin
        -- These tap value stay constant
        taps_in <= ((x"0342", x"0000"), (x"0342", x"0000"), (x"6F00", x"FE00")
                  , (x"0000", x"0000"), (x"04E3", x"0354"), (x"7001", x"0000")
                  , (x"0342", x"0453"), (x"EEEE", x"0000"), (x"0000", x"FFFF")
                  , (x"FFFF", x"0000"), (x"04F3", x"0533"), (x"0435", x"0000")
                  , (x"0243", x"0000"), (x"0000", x"0000"), (x"0453", x"0111")
                  , (x"0000", x"0000"));
        -- Input data in reverse order so that tap0 lines up with data0
        for i in n_taps - 1 downto 0 loop
            data_in <= input_data(i);
            wait for 20 ns;
        end loop;
        -- Calculate what the output should be. Need to use intermediates and
        -- waits since VHDL isn't very flexible.
        for i in 0 to n_taps - 1 loop
            im_value00 <= std_logic_vector(signed(input_data(i)(0)) * signed(taps_in(i)(0)));
            wait for 0.01 ns;
            im_value01 <= std_logic_vector(signed(input_data(i)(1)) * signed(taps_in(i)(1)));
            wait for 0.01 ns;
            im_value0_16 <= im_value00(30 downto 15);
            wait for 0.01 ns;
            im_value1_16 <= im_value01(30 downto 15);
            wait for 0.01 ns;
            im_value0_16 <= std_logic_vector(signed(im_value0_16) - signed(im_value1_16));
            wait for 0.01 ns;
            out_value(0) <= std_logic_vector(signed(out_value(0)) + signed(im_value0_16));
            wait for 0.01 ns;
            im_value00 <= std_logic_vector(signed(input_data(i)(1)) * signed(taps_in(i)(0)));
            wait for 0.01 ns;
            im_value01 <= std_logic_vector(signed(input_data(i)(0)) * signed(taps_in(i)(1)));
            wait for 0.01 ns;
            im_value0_16 <= im_value00(30 downto 15);
            wait for 0.01 ns;
            im_value1_16 <= im_value01(30 downto 15);
            wait for 0.01 ns;
            im_value0_16 <= std_logic_vector(signed(im_value0_16) + signed(im_value1_16));
            wait for 0.01 ns;
            out_value(1) <= std_logic_vector(signed(out_value(1)) + signed(im_value0_16));
            wait for 0.01 ns;
        end loop;
        assert(std_match(out_value(0), data_out(0)));
        assert(std_match(out_value(1), data_out(1)));
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

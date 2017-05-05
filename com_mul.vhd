----------------------------------------------------------------------------
--
--  Complex Array Multiplier
--
--  This is an implementation of a complex array multiplier. It is entirely
--  combinational, and consists of 4 parallel multipliers.
--
--  Revision History:
--      2017-04-24   Harrison Krowas   Initial Revision
----------------------------------------------------------------------------

--  COM_MUL_ARRAY
--
--  Inputs:
--      z  -  First complex multiplicand
--      w  -  Second complex multiplicand
--
--  Outputs:
--      c  -  Complex product
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.tap_array.all;

entity COM_MUL_ARRAY is
    generic (
        n  :  integer := 16
    );
    port (
        z  :  in  com;
        w  :  in  com;
        c  :  out com
    );
end COM_MUL_ARRAY;

architecture COM_MUL_ARRAY_ARCH of COM_MUL_ARRAY is
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
    signal xu  :  std_logic_vector(15 downto 0);
    signal yv  :  std_logic_vector(15 downto 0);
    signal yu  :  std_logic_vector(15 downto 0);
    signal xv  :  std_logic_vector(15 downto 0);
    signal xu_32  :  std_logic_vector(31 downto 0);
    signal yv_32  :  std_logic_vector(31 downto 0);
    signal yu_32  :  std_logic_vector(31 downto 0);
    signal xv_32  :  std_logic_vector(31 downto 0);
begin
    XU_MUL : MUL_ARRAY
    port map (
        x => z(0),
        y => w(0),
        z => xu_32
    );
    YV_MUL : MUL_ARRAY
    port map (
        x => z(1),
        y => w(1),
        z => yv_32
    );
    YU_MUL : MUL_ARRAY
    port map (
        x => z(1),
        y => w(0),
        z=> yu_32
    );
    XV_MUL : MUL_ARRAY
    port map (
        x => z(0),
        y => w(1),
        z => xv_32
    );
    xu <= xu_32(30 downto 15);
    yv <= yv_32(30 downto 15);
    yu <= yu_32(30 downto 15);
    xv <= xv_32(30 downto 15);
    c(0) <= xu - yv;
    c(1) <= yu + xv;
end COM_MUL_ARRAY_ARCH;

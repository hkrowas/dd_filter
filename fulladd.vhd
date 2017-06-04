----------------------------------------------------------------------------
--
--  Full Adder in VHDL
--
--  This is an implementation of a full adder in VHDL.  It uses a dataflow
--  type architectures.  Timing information is for example purposes only, it
--  has no meaning for implementation.
--
--  Revision History:
--     16 Apr 98  Glen George       Initial revision.
--      7 Nov 99  Glen George       Updated formatting.
--      6 Nov 05  Glen George       Added timing architecture.
--      6 Nov 05  Glen George       Updated comments.
--      2017-04-13 Harrison Krowas  Delete timing architecture. Change type
--                                  to std_logic
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

--
--  FullAdder entity declaration
--

entity  FullAdder  is

    port (
        A, B  :  in  std_logic;       --  addends
        Cin   :  in  std_logic;       --  carry in input
        Sum   :  out  std_logic;      --  sum output
        Cout  :  out  std_logic       --  carry out output
    );

end  FullAdder;

--
--  FullAdder architecture definitions
--

--  FullAdder dataflow architecture

architecture  dataflow  of  FullAdder  is
begin

    Sum <= A xor B xor Cin;
    Cout <= (A and B) or (A and Cin) or (B and Cin);

end  dataflow;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
--
--  n-Bit Adder
--      parameter (bitsize) is the number of bits in the adder
--

entity  Adder  is

    generic (
        bitsize : integer := 8      -- default width is 8-bits
    );

    port (
        X, Y :  in  std_logic_vector((bitsize - 1) downto 0);     -- addends
        Ci   :  in  std_logic;                                    -- carry in
        S    :  out  std_logic_vector((bitsize - 1) downto 0);    -- sum out
        Cout_m1 : out std_logic;
        Co   :  out  std_logic                                    -- carry out
    );

end  Adder;


architecture  archAdder  of  Adder  is

    component  FullAdder
        port (
            A, B  :  in  std_logic;       --  inputs
            Cin   :  in  std_logic;       --  carry in input
            Sum   :  out  std_logic;      --  sum output
            Cout  :  out  std_logic       --  carry out output
        );
    end  component;

    signal  carry : std_logic_vector(bitsize downto 0);   -- intermediate carries

begin

    carry(0) <= Ci;                         -- put carry in into our carry vector

    Adders:  for i in  X'range  generate    -- generate bitsize full adders
    begin

        FAx: FullAdder  port map  (X(i), Y(i), carry(i), S(i), carry(i + 1));

    end generate;
    Cout_m1 <= carry(carry'high - 1);
    Co <= carry(carry'high);                 -- carry out is from carry vector

end  archAdder;

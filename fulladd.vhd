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

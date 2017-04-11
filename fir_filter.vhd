----------------------------------------------------------------------------
--
--  FIR filter
--
--  This is an implementation of an FIR filter.
--
--  Revision History:
--      2017-04-11   Harrison Krowas   Initial Revision
----------------------------------------------------------------------------

--  FIR_FILTER
--
--  Inputs:
--      clock
--      data_in -  Input data to filter. New data should be given on every clock
--      taps_reset     -  Taps take these values when reset
--      taps_in        -  Taps take these values on every colck
--      reset          -  Sets tap values to taps input
--
--  Outputs:
--      data_out     -  Output data from filter.
--      error_out    -  Computed error signal. Used for testing purposes.
--
--  Generic:
--      n_taps   -  Number of taps

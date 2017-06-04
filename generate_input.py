# ----------------------------------------------------------------------------
# --
# --  Generate Input
# --
# --  This is the script for generating input to the VHDL test bench
# --  (dd_filter_tb). It creates a random input of 16QAM data, rotates it by
# --  30 degrees, and passes it through a Gaussian FIR filter to simulate the
# --  the effets of dispersion in fiber.
# --
# --  Revision History:
# --      2017-06-01   Harrison Krowas   Initial Revision
# ----------------------------------------------------------------------------

import numpy as np
import random
from scipy import signal
import matplotlib.pyplot as plt

random.seed()

def int_to_bin(datain):
    out_string = ""
    twos = 0x8000
    for i in range(16):
        if (datain & twos is not 0):
            out_string += "1"
        else:
            out_string += "0"
        twos = twos >> 1
    return out_string

N = 10000
p2 = 0x3000
p1 = 0x1000
m2 = -p1
m1 = -p2

rotation = 0.2j


constellation = np.array([complex(m2, p2), complex(m1, p2), complex(p1, p2),
complex(p2, p2), complex(m2, p1), complex(m1, p1), complex(p1, p1),
complex(p2, p1), complex(m2, m1), complex(m1, m1), complex(p1, m1),
complex(p2, m1), complex(m2, m2), complex(m1, m2), complex(p1, m2),
complex(p2, m2)])

# Generate input constellation
datain = np.array([constellation[random.randint(0, 15)] for i in range(N)]) * np.exp(rotation)
window = signal.gaussian(5, std=0.45)
window = window / np.sum(window)
datain = signal.convolve(datain, window)


f = open('input', 'w')
error = 0
for i in range(15, N):
    f.write(int_to_bin(int(datain[i].real)) + " ")
    f.write(int_to_bin(int(datain[i].imag)) + " ")
    error += np.min(np.absolute(constellation * np.exp(rotation) - datain[i]))

f.write("\n")
f.write("\n")
print(error / N)

f.close()

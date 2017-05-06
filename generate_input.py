import numpy as np
import random
import matplotlib.pyplot as plt

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
m2 = -p2
m1 = -p1

constellation = np.array([complex(m2, p2), complex(m1, p2), complex (p1, p2),
complex(p2, p2), complex(m2, p1), complex(m1, p1), complex (p1, p1),
complex(p2, p1), complex(m2, m1), complex(m1, m1), complex (p1, m1),
complex(p2, m1), complex(m2, m2), complex(m1, m2), complex (p1, m2),
complex(p2, m2)])

# Generate input constellation
datain = np.array([constellation[random.randint(0, 15)] for i in range(N)])

f = open('input', 'w')

for i in range(N):
    f.write(int_to_bin(int(datain[i].real)) + " ")
    f.write(int_to_bin(int(datain[i].imag)) + " ")

f.close()

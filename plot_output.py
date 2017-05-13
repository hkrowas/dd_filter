import numpy as np
import random
import matplotlib.pyplot as plt

def bin_to_int(strin):
    ret = 0
    if (strin[0] is "0"):
        for i in range(1, 16):
            if (strin[i] is "1"):
                ret += 2**(15 - i)
    else:
        for i in range(1, 16):
            if (strin[i] is "0"):
                ret += 2**(15 - i)
        ret += 1
        ret *= -1
    return ret

N = 1000
p2 = 0x3000
p1 = 0x1000
m2 = -p2
m1 = -p1

constellation = np.array([complex(m2, p2), complex(m1, p2), complex (p1, p2),
complex(p2, p2), complex(m2, p1), complex(m1, p1), complex (p1, p1),
complex(p2, p1), complex(m2, m1), complex(m1, m1), complex (p1, m1),
complex(p2, m1), complex(m2, m2), complex(m1, m2), complex (p1, m2),
complex(p2, m2)])

f = open('output', 'r')

datastr = f.read()
datastr = datastr.rsplit(" ")

data_out = np.array([complex(bin_to_int(datastr[2 * i]), bin_to_int(datastr[2 * i + 1]))
    for i in range(N)])

plt.scatter(data_out.real[:10], data_out.imag[:10])
plt.show()

f.close()

# -*- coding: utf-8 -*-
"""
Created on Tue Feb  2 09:35:26 2021
Updated on Fri May 20 03:52:45 2022

@author: audrey corbeil therrien
"""

import numpy as np
from matplotlib import pyplot as plt

f = 20000      # Fréquence en Hz
fs = 48000       # Fréquence d'échantillonnage
#ne = 10
ne = int(((1/f)/(1/fs)))          # Nombre d'échantillons
print(ne)

def twosCom_dec2Hex24(dec):
        if dec>=0:
                return "{0:06X}".format(dec)
        else:
                bin1 = "{0:024b}".format(dec)
                bin_comp = ''.join('1' if x == '0' else '0' for x in bin1[1:])
                bin_comp2 = '1' + "{0:023b}".format(int(bin_comp,2)+1)
                return "{0:06X}".format(int(bin_comp2, 2))
                 

# Création du sinus
t = np.arange(ne)
#
y = 0.99*np.sin((f*(2*np.pi*t)/(fs))+(0.1*np.pi))
#y = 0.99*np.sin(f*(2*np.pi*t)/(fs))

plt.plot(t,y)
#plt.show()

# Conversion en héxadécimal
y_int = [int(y_i*pow(2, 23)) for y_i in y]
y_hex = [twosCom_dec2Hex24(y_i)  for y_i in y_int]

print(y_hex)

plt.plot(t,[int(y_i,16) for y_i in y_hex],2)

# Écriture dans le format pour VHDL

f_vhdl = open("SignalHexa_Test_{}.txt".format(f), "a")
#f_vhdl = open("SignalHexa_Test2.txt", "a")

for x in range(0, 35):
    for i in range(len(y_hex)):
        data = "{}".format(y_hex[i])
        f_vhdl.write(data)
        f_vhdl.write("\n")

f_vhdl.close()

#plt.show()
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import math

def generateConsts(outFilePath, fractionalBits):
    with open(outFilePath, "w") as f:
        f.write("local FixedConsts = {")
        #number
        f.write("\n    DOT1            = {0},--{1}".format(round(0.1 * (1 << fractionalBits)), 0.1))
        f.write("\n    DOT01           = {0},--{1}".format(round(0.01 * (1 << fractionalBits)), 0.01))
        f.write("\n    DOT001          = {0},--{1}".format(round(0.001 * (1 << fractionalBits)), 0.001))
        f.write("\n    DOT0001         = {0},--{1}".format(round(0.0001 * (1 << fractionalBits)), 0.0001))
        f.write("\n    DOT00001        = {0},--{1}".format(round(0.00001 * (1 << fractionalBits)), 0.00001))
        f.write("\n    DOT000001       = {0},--{1}".format(round(0.000001 * (1 << fractionalBits)), 0.000001))
        f.write("\n    DOT48           = {0},--{1}".format(round(0.48 * (1 << fractionalBits)), 0.48))
        f.write("\n    DOT235          = {0},--{1}".format(round(0.235 * (1 << fractionalBits)), 0.235))
        f.write("\n    DOT95           = {0},--{1}".format(round(0.95 * (1 << fractionalBits)), 0.95))
        
        f.write("\n    SQRT2           = {0},--{1}".format(round(math.sqrt(2) * (1 << fractionalBits)), math.sqrt(2)))
        f.write("\n    HALF_SQRT2      = {0},--{1}".format(round(math.sqrt(2) * (1 << (fractionalBits-1))), math.sqrt(2)/2))
        
        f.write("\n    PI              = {0},--{1}".format(round(math.pi * (1 << fractionalBits)), math.pi))
        f.write("\n    HALF_PI         = {0},--{1}".format(round(math.pi * (1 << (fractionalBits-1))), math.pi / 2))
        f.write("\n    TWO_PI          = {0},--{1}".format(round(math.pi * (1 << (fractionalBits+1))), math.pi * 2))
        f.write("\n    RAD2DEG         = {0},--{1}".format(round(180 / math.pi * (1 << fractionalBits)), 180 / math.pi))
        f.write("\n    DEG2RAD         = {0},--{1}".format(round(math.pi / 180 * (1 << fractionalBits)), math.pi / 180))
        
        f.write("\n    ATAN2_P1        = {0},--{1}".format(round(-0.0464964749 * (1 << fractionalBits)), -0.0464964749))
        f.write("\n    ATAN2_P2        = {0},--{1}".format(round(0.15931422 * (1 << fractionalBits)), 0.15931422))
        f.write("\n    ATAN2_P3        = {0},--{1}".format(round(0.327622764 * (1 << fractionalBits)), 0.327622764))
        #pi table
        f.write("\n    PI_TABLE        = {")
        i = 0
        while True:
            j = math.pi * (1 << fractionalBits + i) + 0.5
            if j > 0x7FFFFFFFFFFFFFFF:
                break
            if i % 10 == 0:
                f.write("\n        ")
            f.write("{0},".format(math.floor(j)))
            i = i + 1
        f.write("\n    },")
        #cos table
        cosTableCount = 3600
        f.write("\n    COS_TABLE       = {")
        for i in range(cosTableCount):
            if i % 10 == 0:
                f.write("\n        ")
            f.write("{0},".format(round(math.cos(i * (math.pi / 2) / cosTableCount) * (1 << fractionalBits))))
            
        f.write("\n    },")
        #end
        f.write("\n}")
        f.write("\n")
        f.write("\nreturn FixedConsts")
if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("usage: \n")
        print("    python generate.py outFilePath fractionalBits")
    else:
        generateConsts(sys.argv[1], int(sys.argv[2]))

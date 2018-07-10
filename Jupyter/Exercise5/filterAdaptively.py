# Please import the following in your main file: 
# import numpy as np
# from scipy import signal as sp

#################################################################################
# Allows for segment-wise filtering of a signal with changing filters.
# Input:  MACoeff        - Moving average filter coefficients (vector)
#         ARCoeff        - Autoregressive filter coefficients (e.g. LPCs) (vector)
#         sigIN          - Input signal segment (vector)
#         filterStateIn  - 'State' of the filter before filtering
# 
# Output: sigOut         - Output signal segment (filtered version of sigIn)
#         filterStateOut - 'State' of the filter after filtering
#
# Usage:  Example for LPC filtering:
#         Call segmentOut, filtState = filterAdaptively(1, LPCs, segmentIn, filtState);
#         for every signal segment, using the corresponding (time varying)
#         LPCs for this frame. 'filterAdaptively' will ensure a correct
#         initialization of the time varying filter for each segment.
#         For the first segment, do not use 'filtState' as an input,
#         'filterAdaptively' will then initialize and return the first
#         filter state.
##################################################################################

def filterAdaptively(MACoeff, ARCoeff, sigIn, filterStateIn=None):
    if np.all(filterStateIn == None):
        filterStateIn = np.zeros(np.max(ARCoeff.shape)-1)
        sigOut, filterStateOut = sp.lfilter(MACoeff, ARCoeff, sigIn, -1, filterStateIn)
    else:
        sigOut, filterStateOut = sp.lfilter(MACoeff, ARCoeff, sigIn, -1, filterStateIn)
       
    return sigOut, filterStateOut

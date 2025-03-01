import matplotlib.pyplot as plt
import numpy as np
from DataLoader.SelfDataLoader import *

def generate_npy_testname(generate_num=800):
    filename = "E:/DataSet"
    Radar = "/Radar_"
    Target = "/Target_"
    Data = "/Data_"
    TargetData = "/TargetData_"
    NoiseData = "/NoiseData_"
    RTargetData = "/RTargetData_"
    RNoiseData = "/RNoiseData_"
    Label = "/Label_"
    Signal = "/Signal_"

    fR = []
    fT = []
    fD = []
    fTD = []
    fND = []
    fRTD = []
    fRND = []
    fL = []
    fS = []
    fff = 6
    for ff in range(generate_num):
        filenameRadar = filename + str(fff) + Radar + str(ff + 1) + ".npy"
        filenameTarget = filename + str(fff) + Target + str(ff + 1) + ".npy"
        filenameData = filename + str(fff) + Data + str(ff + 1) + ".npy"
        filenameTargetData = filename + str(fff) + TargetData + str(ff + 1) + ".npy"
        filenameNoiseData = filename + str(fff) + NoiseData + str(ff + 1) + ".npy"
        filenameRTargetData = filename + str(fff) + RTargetData + str(ff + 1) + ".npy"
        filenameRNoiseData = filename + str(fff) + RNoiseData + str(ff + 1) + ".npy"
        filenameLabel = filename + str(fff) + Label + str(ff + 1) + ".npy"
        filenameSignal = filename + str(fff) + Signal + str(ff + 1) + ".npy"

        fR.append(filenameRadar)
        fT.append(filenameTarget)
        fD.append(filenameData)
        fTD.append(filenameTargetData)
        fND.append(filenameNoiseData)
        fRTD.append(filenameRTargetData)
        fRND.append(filenameRNoiseData)
        fL.append(filenameLabel)
        fS.append(filenameSignal)

    return fR, fT, fD, fTD, fND, fRTD, fRND, fL, fS

def generate_npy_dataname(generate_num=3000):
    fNum = 5
    filename     = "E:/DataSet"
    Radar        = "/Radar_"
    Target       = "/Target_"
    Data         = "/Data_"
    TargetData   = "/TargetData_"
    NoiseData    = "/NoiseData_"
    RTargetData  = "/RTargetData_"
    RNoiseData   = "/RNoiseData_"
    Label        = "/Label_"
    Signal       = "/Signal_"

    fR   = []
    fT   = []
    fD   = []
    fTD  = []
    fND  = []
    fRTD = []
    fRND = []
    fL   = []
    fS   = []

    for fff in range(fNum):
        fff = fff + 1
        for ff in range(generate_num):
            if fff <= 3:
                filename = "D:/2024/Passive_Radar_Localization/DatasetGenerate/DataSet"
            else:
                filename = "E:/DataSet"
            filenameRadar      = filename + str(fff) + Radar + str(ff + 1) + ".npy"
            filenameTarget     = filename + str(fff) + Target + str(ff + 1) + ".npy"
            filenameData       = filename + str(fff) + Data + str(ff + 1) + ".npy"
            filenameTargetData = filename + str(fff) + TargetData + str(ff + 1) + ".npy"
            filenameNoiseData  = filename + str(fff) + NoiseData + str(ff + 1) + ".npy"
            filenameRTargetData = filename + str(fff) + RTargetData + str(ff + 1) + ".npy"
            filenameRNoiseData  = filename + str(fff) + RNoiseData + str(ff + 1) + ".npy"
            filenameLabel      = filename + str(fff) + Label + str(ff + 1) + ".npy"
            filenameSignal     = filename + str(fff) + Signal + str(ff + 1) + ".npy"

            fR.append(filenameRadar)
            fT.append(filenameTarget)
            fD.append(filenameData)
            fTD.append(filenameTargetData)
            fND.append(filenameNoiseData)
            fRTD.append(filenameRTargetData)
            fRND.append(filenameRNoiseData)
            fL.append(filenameLabel)
            fS.append(filenameSignal)

    return fR, fT, fD, fTD, fND, fRTD, fRND, fL, fS

if __name__=='__main__':
    fR, fT, fD, fTD, fND, fLTD, fLND, fL, fS = generate_data_sets_text()
    fR2, fT2, fD2, fTD2, fND2, fLTD2, fLND2, fL2, fS2 = generate_npy_testname()
    for ii in range(len(fR)):
        print("{} / {}".format(ii, len(fR)))
        Maps = map_convert_to_numpy(fD[ii], "Maps")
        MapnMap = map_convert_to_numpy(fND[ii], "RMapsN")
        MaptMap = map_convert_to_numpy(fTD[ii], "RMapsT")
        MapLnMap = map_convert_to_numpy(fLND[ii], "LMapsN")
        MapLtMap = map_convert_to_numpy(fLTD[ii], "LMapsT")
        Maplabel = map_convert_to_numpy(fL[ii], "label")
        np.save(fD2[ii], Maps)
        np.save(fND2[ii], MapnMap)
        np.save(fTD2[ii], MaptMap)
        np.save(fLND2[ii], MapLnMap)
        np.save(fLTD2[ii], MapLtMap)
        np.save(fL2[ii], Maplabel)
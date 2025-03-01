import torch
from DataLoader.SelfDataLoader import *
from torch.utils.data import Dataset, DataLoader
import numpy as np
from Utilize.GetDataSets import *

class SpaceDatasetAll(Dataset):
    def __init__(self, test=True):
        if test:
            fR, fT, fD, fTD, fND, fLTD, fLND, fL, fS = generate_npy_testname()
        else:
            fR, fT, fD, fTD, fND, fLTD, fLND, fL, fS = generate_npy_dataname()
        self.fileMap      = fD
        self.fileMapnMap  = fND
        self.fileMaptMap  = fTD
        self.fileMapLnMap  = fLND
        self.fileMapLtMap  = fLTD
        self.fileMaplabel = fL
        self.fileRadar    = fR

    def __len__(self):
        return len(self.fileMap)

    def __getitem__(self, idx):
        # print(idx)
        # Num = sio.loadmat(self.fileMapnMap[idx])['RMapsN']
        # Num = Num.shape[1]
        Num = np.load(self.fileMapnMap[idx], allow_pickle=True)
        # Num = Num.shape[0]
        Num = 4

        Maps = np.load(self.fileMap[idx], allow_pickle=True)
        Maplabel = np.load(self.fileMaplabel[idx])

        maps = []
        for ii in range(Num):
            map = torch.from_numpy(Maps[ii])
            map = map.permute(2, 0, 1)
            maps.append(map)

        Maplabel = torch.from_numpy(Maplabel)
        Maplabel = Maplabel.permute(2, 0, 1)
        MapLabel = torch.zeros_like(Maplabel)

        # 重新制备标签
        Mapindice = torch.nonzero(Maplabel >= 1e1)
        for ii in range(Mapindice.shape[0]):
            if (Maplabel[Mapindice[ii][0]][Mapindice[ii][1]][Mapindice[ii][2]] * 1e1 < 1e3):
                MapLabel[Mapindice[ii][0]][Mapindice[ii][1]][Mapindice[ii][2]] = (
                        Maplabel[Mapindice[ii][0]][Mapindice[ii][1]][Mapindice[ii][2]] * 1e1)
            else:
                MapLabel[Mapindice[ii][0]][Mapindice[ii][1]][Mapindice[ii][2]] = 1e3

        return maps, MapLabel
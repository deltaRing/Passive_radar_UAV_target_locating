import torch
from DataLoader.SelfDataLoader import *
from Utilize.GetDataSets import *
from torch.utils.data import Dataset, DataLoader
import numpy as np

class SpaceDataset(Dataset):
    def __init__(self):
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
        Num = np.load(self.fileMapnMap[idx], allow_pickle=True)
        Num = Num.shape[0]
        SelectID = np.random.randint(0, Num)
        # Maps     = map_convert_to_numpy(self.fileMap[idx], "Maps")
        # MapnMap  = map_convert_to_numpy(self.fileMapnMap[idx], "RMapsN")
        # MaptMap  = map_convert_to_numpy(self.fileMaptMap[idx], "RMapsT")
        # MapLnMap  = map_convert_to_numpy(self.fileMapLnMap[idx], "LMapsN")
        # MapLtMap  = map_convert_to_numpy(self.fileMapLtMap[idx], "LMapsT")
        # Maplabel = map_convert_to_numpy(self.fileMaplabel[idx], "label")
        Maps = np.load(self.fileMap[idx], allow_pickle=True)
        MapnMap = np.load(self.fileMapnMap[idx], allow_pickle=True)
        MaptMap = np.load(self.fileMaptMap[idx], allow_pickle=True)
        MapLnMap = np.load(self.fileMapLnMap[idx], allow_pickle=True)
        MapLtMap = np.load(self.fileMapLtMap[idx], allow_pickle=True)
        # Maplabel = np.load(self.fileMaplabel[idx])

        Maps = torch.from_numpy(Maps[SelectID])
        MapnMap = torch.from_numpy(MapnMap[SelectID])
        MaptMap  = torch.from_numpy(MaptMap[SelectID])
        MapLnMap  = torch.from_numpy(MapLnMap[SelectID])
        MapLtMap  = torch.from_numpy(MapLtMap[SelectID])

        Maps     = Maps.permute(2, 0, 1)
        MapnMap  = MapnMap.permute(2, 0, 1)
        MaptMap  = MaptMap.permute(2, 0, 1)
        MapLnMap = MapLnMap.permute(2, 0, 1)
        MapLtMap = MapLtMap.permute(2, 0, 1)

        return Maps, MapnMap, MaptMap, MapLtMap, MapLnMap
import torch
import torch as t
import torch.nn as nn
import torch.nn.functional as F

# Prob Multiple for positioning the target
#
#
#
#
#
#

class MultiplyNetworks(nn.Module):
    def __init__(self,
                 input_size_x=256,
                 input_size_y=256,
                 input_size_z=128,
                 output_size_x=256,
                 output_size_y=256,
                 output_size_z=128):
        super(MultiplyNetworks, self).__init__()
        self.Xsize = input_size_x
        self.Ysize = input_size_y
        self.Zsize = input_size_z
        self.OXsize = output_size_x
        self.OYsize = output_size_y
        self.OZsize = output_size_z

        self.SeqLayer0 = nn.Sequential(
            nn.Conv2d(self.Zsize, self.OZsize, kernel_size=[3, 3], padding=1),
            nn.ReLU(),  # 概率分布 0 ~ 1
            nn.Dropout(p=0.5),
            nn.BatchNorm2d(self.OZsize),  # 128 x 128 x 64
        )

        self.SeqLayer1 = nn.Sequential(
            nn.Conv2d(self.Zsize, self.OZsize, kernel_size=[7, 7], padding=3),
            nn.ReLU(),  # 概率分布 0 ~ 1
            nn.Dropout(p=0.5),
            nn.BatchNorm2d(self.OZsize),  # 128 x 128 x 64
        )

        self.SeqLayer2 = nn.Sequential(
            nn.Conv2d(self.Zsize, self.OZsize, kernel_size=[11, 11], padding=5),
            nn.ReLU(),  # 概率分布 0 ~ 1
            nn.Dropout(p=0.5),
            nn.BatchNorm2d(self.OZsize),  # 128 x 128 x 64
        )

        self.SeqLayer3 = nn.Sequential(
            nn.Conv2d(self.Zsize, self.OZsize, kernel_size=[15, 15], padding=7),
            nn.ReLU(),  # 概率分布 0 ~ 1
            nn.Dropout(p=0.5),
            nn.BatchNorm2d(self.OZsize),  # 128 x 128 x 64
        )

        self.SeqVar = nn.Sequential(
            nn.Conv2d(self.Zsize, self.OZsize, kernel_size=[15, 15], padding=7),
            nn.ReLU(),  # 概率分布 0 ~ 1
            nn.Dropout(p=0.5),
            nn.BatchNorm2d(self.OZsize),  # 128 x 128 x 64
        )

        self.SeqMu = nn.Sequential(
            nn.Conv2d(self.Zsize, self.OZsize, kernel_size=[15, 15], padding=7),
            nn.ReLU(),  # 概率分布 0 ~ 1
            nn.Dropout(p=0.5),
            nn.BatchNorm2d(self.OZsize),  # 128 x 128 x 64
        )

        self.SeqEx  = nn.Sequential(
            nn.Conv2d(self.OZsize, self.OZsize, kernel_size=[19, 19], padding=9),
            nn.ReLU(),  # 概率分布 0 ~ 1
            nn.Dropout(p=0.5),
            nn.BatchNorm2d(self.OZsize),  # 128 x 128 x 64
            nn.Conv2d(self.OZsize, self.OZsize, kernel_size=[19, 19], padding=9),
            nn.ReLU(),  # 128 x 128 x 64
        )

    def forward(self, X):
        X0 = self.SeqLayer0(X)
        X1 = self.SeqLayer1(X0)
        X2 = self.SeqLayer2(X1)
        X3 = self.SeqLayer3(X2)
        #get_mu  = self.SeqMu(X3)
        #get_var = torch.exp(0.5 * self.SeqVar(X3))
        #noise   = self.get_randn(get_var)
        #feat    = get_mu + noise * get_var # modified to fit distribution
        Ex      = self.SeqEx(X3)
        Ex      = X3 + Ex
        return Ex

    def get_randn(self, X):
        return torch.randn_like(X)
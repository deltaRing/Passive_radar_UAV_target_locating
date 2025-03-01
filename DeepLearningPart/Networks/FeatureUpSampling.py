import torch as t
import torch.nn as nn
import torch.nn.functional as F

# 64 x 64 x 32 --> 256 x 256 x 64
# input: the feat from the Refine_Networks
#
# output the mask for the X

class FeatureUpSamplingNet(nn.Module):
    def __init__(self,
                 input_size_x=64,
                 input_size_y=64,
                 input_size_z=32,
                 output_size_x=256,
                 output_size_y=256,
                 output_size_z=128):
        super(FeatureUpSamplingNet, self).__init__()
        self.Xsize = input_size_x
        self.Ysize = input_size_y
        self.Zsize = input_size_z
        self.OXsize = output_size_x
        self.OYsize = output_size_y
        self.OZsize = output_size_z

        self.Seq1 = nn.Sequential(
            nn.ConvTranspose2d(self.Zsize, self.OZsize // 2, [4, 4], stride=[2, 2], padding=1),
            nn.BatchNorm2d(self.OZsize // 2),
            nn.Sigmoid(),
            nn.Dropout(p=0.5),
            nn.Conv2d(self.OZsize // 2, self.OZsize // 2, [3, 3], padding=1),
            nn.BatchNorm2d(self.OZsize // 2),
            nn.Sigmoid(),
            nn.Dropout(p=0.5),
            nn.Conv2d(self.OZsize // 2, self.OZsize // 2, [3, 3], padding=1),
            nn.BatchNorm2d(self.OZsize // 2),
        )

        self.SeqEx = nn.Sequential(
            nn.ConvTranspose2d(self.OZsize // 2, self.OZsize, [4, 4], stride=[2, 2], padding=1),
            nn.BatchNorm2d(self.OZsize),
            nn.Sigmoid(),
            nn.Conv2d(self.OZsize, self.OZsize, [3, 3], padding=1),
            nn.BatchNorm2d(self.OZsize),
            nn.Sigmoid(),
        )

    def forward(self, X):
        feat1 = self.Seq1(X)
        Ex    = self.SeqEx(feat1)

        return feat1, Ex


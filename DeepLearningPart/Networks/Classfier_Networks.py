import torch as t
import torch.nn as nn
import torch.nn.functional as F

# 空间目标分类器
#
#
#
#
class ClassfierNetworks(nn.Module):
    def __init__(self,
                 input_size_x=16,
                 input_size_y=16,
                 input_size_z=32,
                 output_size =1,
                 ):
        super(ClassfierNetworks, self).__init__()
        self.Isize = input_size_x * input_size_y * input_size_z
        self.Osize = output_size

        self.model1 = nn.Sequential(
            nn.Linear(self.Isize, self.Isize // 2),
            nn.Sigmoid(),
            nn.Dropout(p=0.5),
            nn.BatchNorm1d(self.Isize // 2),
            nn.Linear(self.Isize // 2, self.Isize // 4),
            nn.Sigmoid(),
            nn.BatchNorm1d(self.Isize // 4),
        )

        self.model2 = nn.Sequential(
            nn.Linear(self.Isize // 4, self.Isize // 8),
            nn.Sigmoid(),
            nn.Dropout(p=0.5),
            nn.BatchNorm1d(self.Isize // 8),
            nn.Linear(self.Isize // 8, self.Isize // 16),
            nn.Sigmoid(),
            nn.BatchNorm1d(self.Isize // 16),
        )

        self.model3 = nn.Sequential(
            nn.Linear(self.Isize // 16, self.Isize // 32),
            nn.Sigmoid(),
            nn.Dropout(p=0.5),
            nn.BatchNorm1d(self.Isize // 32),
            nn.Linear(self.Isize // 32, self.Isize // 64),
            nn.Sigmoid(),
            nn.BatchNorm1d(self.Isize // 64),
        )

        self.classifier = nn.Sequential(
            nn.Linear(self.Isize // 64, self.Osize),
            nn.Sigmoid(),
        )

    def forward(self, X):
        if len(X.shape) == 4:
            X = X.reshape([-1, self.Isize])
        feat1 = self.model1(X)
        feat2 = self.model2(feat1)
        feat3 = self.model3(feat2)
        result = self.classifier(feat3)

        return feat1, feat2, feat3, result
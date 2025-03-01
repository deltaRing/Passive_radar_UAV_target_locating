import torch as t
import torch.nn
import torch.nn as nn
import torch.nn.functional as F

# 这个网络是用于提取存在目标分布的区域
# 利用注意力机制
# 在分类输出的权重上标注目标所存在的区域
# 输出 1： 目标
# 输出 0： 噪声
class RefinaryNetworks(nn.Module):
    # nn.Module
    def __init__(self,
                 input_size_x=256, # 输入Xsize
                 input_size_y=256, # 输入Ysize
                 input_size_z=128, # 输入Zsize
                 output_depth=32,  # 输出Channel
                 ):
        super(RefinaryNetworks, self).__init__()
        self.Xsize = input_size_x
        self.Ysize = input_size_y
        self.Zsize = input_size_z
        self.Osize = output_depth
        self.grad  = []
        self.acti  = []

        #define the hook function for obtain the grad
        def forword_hook(module, input, output):
            self.acti = output

        def backward_hook(module, grad_in, grad_out):
            self.grad = grad_out

        # 压缩角度值 256 x 256 x 128 --> 32 x 32 x 16
        self.Seq1  = nn.Sequential(
            nn.Conv2d(self.Zsize, self.Zsize // 2, kernel_size=[3, 3], padding=1),
            nn.Sigmoid(), # 概率分布 0 ~ 1
            nn.MaxPool2d(kernel_size=[2, 2]),
            nn.BatchNorm2d(self.Zsize // 2), # 128 x 128 x 64
            nn.Dropout(p=0.5),
        )

        # 128 x 128 x 64 --> 64 x 64 x 32
        self.Seq2  = nn.Sequential(
            nn.Conv2d(self.Zsize // 2, self.Zsize // 4, kernel_size=[3, 3], padding=1),
            nn.Sigmoid(),
            nn.MaxPool2d(kernel_size=[2, 2]),
            nn.BatchNorm2d(self.Zsize // 4),  # 64 x 64 x 32
        )

        # 64 x 64 x 32 --> 32 x 32 x 16
        self.Seq3  = nn.Sequential(
            nn.Conv2d(self.Zsize // 4, self.Zsize // 8, kernel_size=[3, 3], padding=1),
            nn.Sigmoid(),
            nn.MaxPool2d(kernel_size=[2, 2]),
            nn.BatchNorm2d(self.Zsize // 8),  # 32 x 32 x 16
            nn.Dropout(p=0.5),
        )

        # 扩展深度值 32 x 32 x 16 --> 16 x 16 x 64
        self.SeqEx  = nn.Sequential(
            nn.Conv2d(self.Zsize // 8, self.Osize // 4, kernel_size=[3, 3], padding=1),
            nn.Sigmoid(),
            nn.MaxPool2d(kernel_size=[2, 2]),
            nn.BatchNorm2d(self.Osize // 4),  # 32 x 32 x 32
            nn.Dropout(p=0.5),
            nn.Conv2d(self.Osize // 4, self.Osize, kernel_size=[3, 3], padding=1),
            nn.Sigmoid(),
        )

        list(self.Seq3)[0].register_forward_hook(forword_hook)
        list(self.Seq3)[0].register_backward_hook(backward_hook)

        #    Z
        #    /\               ####
        #     |  ###         ###### <----- 1 (目标潜在区域)
        #     | ####         #####
        #     |######       ####
        #     | #####      ###
        #     |  ####     ###
        #     /----###---##--------> Y
        #    /      ##  ##
        #   /        ###
        # \_
        # X

    # 前向传播模块
    def forward(self, X):
        feat1 = self.Seq1(X)
        feat2 = self.Seq2(feat1)
        feat3 = self.Seq3(feat2) # 64 x 64 x 32
        Ex    = self.SeqEx(feat3)

        return feat1, feat2, feat3, Ex

    def get_grad_cam(self):
        grad = self.grad[0] / self.grad[0].shape[2] / self.grad[0].shape[3]
        grad = torch.nn.functional.relu(grad)

        return grad
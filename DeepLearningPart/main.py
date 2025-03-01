import numpy as np
import torch
import torchvision
from torch.utils.tensorboard import SummaryWriter
import os
from tqdm import tqdm
from torch.optim import *
from Networks.loss_functions import *
from Networks.Refine_networks import *
from Networks.Classfier_Networks import *
from Networks.FeatureUpSampling import *
from Networks.Multiply_Networks import *
from DataLoader.SpaceDataset import *

from sklearn.manifold import TSNE
import matplotlib.pyplot as plt

if torch.cuda.is_available():
    device = 'cuda'
else:
    device = 'cpu'

ReFineNetwork    = RefinaryNetworks().to(device)
ClassifyNetwork  = ClassfierNetworks().to(device)
MaskNetwork      = FeatureUpSamplingNet().to(device)
MultiNetworks    = MultiplyNetworks().to(device)
num_epochs = 50
batches    = 8
threads    = 8

train_datasets = SpaceDataset()
train_loader = DataLoader(train_datasets, batch_size=batches, shuffle=True, num_workers=threads)
model_save_path = "./SavedModel/"
model_name      = "model.pth"

# loss_clst = cross_entropy(label_truth, pred_truth)
# loss_clsn = cross_entropy(label_fake, pred_noise)
# loss_exc  = cross_entropy(label_truth, result)
# loss_mse1  = mse_func(MaptMap, Ex)
# loss_mse2  = inverse_sigmoid_mse_func(MapnMap, Ex)
# loss_lmse = mse_func(MapLtMap, feat2)
# lose_nmse = inverse_sigmoid_mse_func(MapLnMap, feat2)


model_loss_clst_save_path = 'loss_model_clst.npy'
model_loss_clsn_save_path = 'loss_model_clsn.npy'
model_loss_exe_save_path = 'loss_model_exe.npy'
model_loss_mse1_save_path = 'loss_model_mse1.npy'
model_loss_mse2_save_path = 'loss_model_mse2.npy'
model_loss_lmse_save_path = 'loss_model_lmse.npy'
model_loss_nmse_save_path = 'loss_model_nmse.npy'
model_loss_clst = np.load(model_loss_clst_save_path).tolist()
model_loss_clsn = np.load(model_loss_clsn_save_path).tolist()
model_loss_exe  = np.load(model_loss_exe_save_path).tolist()
model_loss_mse1 = np.load(model_loss_mse1_save_path).tolist()
model_loss_mse2 = np.load(model_loss_mse2_save_path).tolist()
model_loss_lmse = np.load(model_loss_lmse_save_path).tolist()
model_loss_nmse = np.load(model_loss_nmse_save_path).tolist()

# set up the optimizer
optimizer_space = Adam([{'params': ReFineNetwork.parameters()},
                        {'params': ClassifyNetwork.parameters()}], lr=1e-4)

if __name__=='__main__':
    # check file is exist or not
    maker = ['o', 'v', '^', 's', 'p', '*', '<', '>', 'D', 'd', 'h', 'H']  # 设置散点形状
    colors = ['r', 'c', 'b', 'g', 'm', 'y', 'k', 'w']  # 设置散点颜色

    if os.path.exists(model_save_path + model_name):
        checkpoint = torch.load(model_save_path + model_name)
        ReFineNetwork.load_state_dict(checkpoint['model_RefineNetwork'])
        ClassifyNetwork.load_state_dict(checkpoint['model_ClassifyNetwork'])
        # MaskNetwork.load_state_dict(checkpoint['model_MaskNetwork'])

    for epoch in range(num_epochs):
        loss_mse_total = [] # for the CNN
        loss_cls_total = [] # for the classifier
        loss_msk_total = [] # for indicating the accuracy

        l_clst = []
        l_clsn = []
        l_exe = []
        l_mse1 = []
        l_mse2 = []
        l_lmse = []
        l_nmse = []

        Feats  = []
        Labels = []

        for Maps, MapnMap, MaptMap, MapLtMap, MapLnMap in tqdm(train_loader, ncols=80, desc="Training"):
            Maps     = Maps.to(device)
            MapnMap  = MapnMap.to(device)
            MaptMap  = MaptMap.to(device)
            MapLnMap = MapLnMap.to(device)
            MapLtMap = MapLtMap.to(device)
            # optimize the Ex by utilize the pred_truth
            label_truth = torch.ones(size=[Maps.shape[0], 1]).to(device)
            label_fake  = torch.zeros(size=[Maps.shape[0], 1]).to(device)
            optimizer_space.zero_grad()

            feat1, feat2, feat3, Ex = ReFineNetwork(Maps)
            # utilize the feat3 for the MSE loss
            feat4, feat5, feat6, result = ClassifyNetwork(Ex)

            # manual optimize the classifier
            feat_t1, feat_t2, feat_t3, pred_truth = ClassifyNetwork(MaptMap)
            feat_n1, feat_n2, feat_n3, pred_noise = ClassifyNetwork(MapnMap)
            # feat_t = feat_t3
            # feat_n = feat_n3
            # # record the feature and stack them
            # if len(Feats) == 0:
            #     Feats = feat_t.detach().cpu().numpy()
            #     Feats = np.vstack([Feats, feat_n.detach().cpu().numpy()])
            #     Labels = np.ones([1, batches])
            #     Labels = np.hstack([Labels, np.zeros([1, batches])])
            # else:
            #     Feats = np.vstack([Feats, feat_t.detach().cpu().numpy()])
            #     Feats = np.vstack([Feats, feat_n.detach().cpu().numpy()])
            #     Labels = np.hstack([Labels, np.ones([1, batches])])
            #     Labels = np.hstack([Labels, np.zeros([1, batches])])
            #
            # if Feats.shape[0] >= 500:
            #     X_embedded = TSNE(n_components=2, learning_rate='auto',
            #                       init='random', perplexity=3).fit_transform(Feats)
            #     x_min, x_max = np.min(X_embedded, 0), np.max(X_embedded, 0)
            #     X_embedded = (X_embedded - x_min) / (x_max - x_min)
            #
            #     fig = plt.figure()
            #     ax = plt.subplot(111)
            #     for i in range(X_embedded.shape[0]):
            #         X = X_embedded[i][0]
            #         Y = X_embedded[i][1]
            #         plt.scatter(X, Y, cmap='brg', s=25, marker=maker[0],
            #                     c=colors[int(Labels[0][i])], edgecolors=colors[int(Labels[0][i])],
            #                     alpha=0.65)
            #     plt.xticks([-.1, 1.1])  # 坐标轴设置
            #     plt.yticks([-.1, 1.1])
            #     plt.show(block=True)
            #     Feats = []

            # the masks
            # _, mask = MaskNetwork(feat2)
            # 令classifier进行优化
            loss_clst = cross_entropy(label_truth, pred_truth)
            loss_clsn = cross_entropy(label_fake, pred_noise)
            loss_exc  = cross_entropy(label_truth, result)
            loss_mse1  = mse_func(MaptMap, Ex)
            loss_mse2  = inverse_sigmoid_mse_func(MapnMap, Ex)
            loss_lmse = mse_func(MapLtMap, feat2)
            lose_nmse = inverse_sigmoid_mse_func(MapLnMap, feat2)
            loss_classifier = loss_clst + loss_clsn + loss_exc

            l_clst.append(loss_clst.detach().cpu().numpy())
            l_clsn.append(loss_clsn.detach().cpu().numpy())
            l_exe.append(loss_exc.detach().cpu().numpy())
            l_mse1.append(loss_mse1.detach().cpu().numpy())
            l_mse2.append(loss_mse2.detach().cpu().numpy())
            l_lmse.append(loss_lmse.detach().cpu().numpy())
            l_nmse.append(lose_nmse.detach().cpu().numpy())

            # loss_classifier.backward(retain_graph=True)
            # the classifier
            loss_cnn = loss_mse1 + loss_mse2 + loss_lmse + lose_nmse
            lose_total = 1e4 * loss_cnn + loss_classifier * 1e1
            lose_total.backward()
            # the masks
            # loss_mask = greater_mask(Maps, mask)
            # loss_mask.backward()
            # observe the result
            # name_feat2 = 'feat2'
            # name_MapLtMap = 'MapLtMap'
            # feat2      = feat2.detach().cpu().numpy()
            # MapLtMap   = MapLtMap.detach().cpu().numpy()
            # save_mat(name_feat2, feat2, 'feat2.mat')
            # save_mat(name_MapLtMap, MapLtMap, 'MapLtMap.mat')
            # loss
            # loss_msk_total.append(loss_mask.detach().cpu().numpy())
            loss_mse_total.append(loss_cnn.detach().cpu().numpy())
            loss_cls_total.append(loss_classifier.detach().cpu().numpy())

            optimizer_space.step()

        torch.save(
            {
                'model_RefineNetwork': ReFineNetwork.state_dict(),
                'model_ClassifyNetwork': ClassifyNetwork.state_dict(),
                # 'model_MaskNetwork': MaskNetwork.state_dict(),
            },
            model_save_path + model_name
        )
        print(np.mean(np.array(loss_mse_total)))
        print(np.mean(np.array(loss_cls_total)))

        model_loss_clst.append(np.mean(np.array(l_clst)))
        model_loss_clsn.append(np.mean(np.array(l_clsn)))
        model_loss_exe.append(np.mean(np.array(l_exe)))
        model_loss_mse1.append(np.mean(np.array(l_mse1)))
        model_loss_mse2.append(np.mean(np.array(l_mse2)))
        model_loss_lmse.append(np.mean(np.array(l_lmse)))
        model_loss_nmse.append(np.mean(np.array(l_nmse)))
        np.save(model_loss_clst_save_path, model_loss_clst)
        np.save(model_loss_clsn_save_path, model_loss_clsn)
        np.save(model_loss_exe_save_path, model_loss_exe)
        np.save(model_loss_mse1_save_path, model_loss_mse1)
        np.save(model_loss_mse2_save_path, model_loss_mse2)
        np.save(model_loss_lmse_save_path, model_loss_lmse)
        np.save(model_loss_nmse_save_path, model_loss_nmse)
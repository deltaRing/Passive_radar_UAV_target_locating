import numpy as np
import torch
import os
from tqdm import tqdm
from torch.optim import *
from Networks.loss_functions import *
from Networks.Refine_networks import *
from Networks.Classfier_Networks import *
from Networks.FeatureUpSampling import *
from Networks.Multiply_Networks import *
from DataLoader.SpaceDataset import *
from DataLoader.SpaceDatasetAll import *

if torch.cuda.is_available():
    device = 'cuda'
else:
    device = 'cpu'

ReFineNetwork    = RefinaryNetworks().to(device)
ClassifyNetwork  = ClassfierNetworks().to(device)
MultiNetworks    = MultiplyNetworks().to(device)
num_epochs = 1
batches    = 1
threads    = 1
test = True
train_datasets = SpaceDatasetAll(test)
train_loader = DataLoader(train_datasets, batch_size=batches, shuffle=False, num_workers=threads)
model_save_path = "./SavedModel/"
model_name      = "model.pth"
multi_name      = "multi.pth"

print(MultiNetworks)

# set up the optimizer
optimizer_space = Adam(MultiNetworks.parameters(), lr=1e-4)
upsampleModule  = nn.Upsample(scale_factor=4, mode='nearest')

loss_save = []

if not test and os.path.exists('loss_mul.npy'):
    loss_save = np.load('loss_mul.npy').tolist()

if __name__=='__main__':
    # check file is exist or not
    if os.path.exists(model_save_path + model_name):
        checkpoint = torch.load(model_save_path + model_name)
        ReFineNetwork.load_state_dict(checkpoint['model_RefineNetwork'])
        ClassifyNetwork.load_state_dict(checkpoint['model_ClassifyNetwork'])
        ReFineNetwork = ReFineNetwork.eval()
        ClassifyNetwork = ClassifyNetwork.eval()

    if os.path.exists(model_save_path + multi_name):
        checkpoint = torch.load(model_save_path + multi_name)
        MultiNetworks.load_state_dict(checkpoint['model_MultiNetworks'])
        if test:
            MultiNetworks = MultiNetworks.eval()
        else:
            MultiNetworks = MultiNetworks.train()


    for epoch in range(num_epochs):
        loss_mse_total = [] # for the CNN
        loss_cls_total = [] # for the classifier
        loss_mul_total = [] # for indicating the accuracy
        ii = 0
        for Maps, Maplabel in tqdm(train_loader, ncols=80, desc="Training"):
            ii += 1
            Map_feat = []
            Map_ori  = []
            # get the label of the labels
            for nn in range(len(Maps)):
                maps     = Maps[nn].to(device)
                feat1, feat2, feat3, Ex = ReFineNetwork(maps)
                if len(Map_feat) == 0:
                    Map_feat = feat2
                    Map_ori  = maps
                else:
                    Map_feat = Map_feat * feat2
                    Map_ori  = Map_ori  * maps
            label = Maplabel.to(device)

            optimizer_space.zero_grad()
            # manual optimize the classifier
            tempFeat = Map_feat.reshape([batches, 1, 32, 64, 64])
            Feat = upsampleModule(tempFeat)
            Feat = Feat.squeeze()
            # loss_msk_total.append(loss_mask.detach().cpu().numpy())
            if len(Feat.shape) == 3:
                Feat = Feat.view(1, 128, 256, 256)

            if test:
                with torch.no_grad():
                    pred = MultiNetworks(Feat)
            else:
                pred = MultiNetworks(Feat)

            if test:
                save_mat('Feat',  Feat.detach().cpu().numpy(), str(ii) + 'Feat.mat')
                save_mat('pred', pred.detach().cpu().numpy(), str(ii) + 'pred.mat')
                save_mat('Maplabel', Maplabel.detach().cpu().numpy(), str(ii) + 'Maplabel.mat')
                save_mat('Map_ori', Map_ori.detach().cpu().numpy(), str(ii) + 'Map_ori.mat')

            loss = mse_func(label, pred)
            loss_mul_total.append(loss.detach().cpu().numpy())
            if not test:
                loss.backward()
                optimizer_space.step()

        if not test:
            torch.save(
                {
                    'model_MultiNetworks': MultiNetworks.state_dict(),
                },
                model_save_path + multi_name
            )
            loss_save.append(np.mean(np.array(loss_mul_total)))
            np.save('loss_mul.npy', np.array(loss_save))
        print(np.mean(np.array(loss_mul_total)))

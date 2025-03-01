#导入数据集的包
import torchvision.datasets
#导入dataloader的包
from torch.utils.data import DataLoader
# matlab 读取
import scipy.io as sio
from scipy.io import savemat

# 生成数据集
def generate_data_sets_text(generate_num=800):
    filename     = "D:/2024/Passive_Radar_Localization/DatasetGenerate/DataSet"
    filenum      = 1
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

    for fff in range(filenum):
        # fff += 6
        fff += 6
        for ff in range(generate_num):
            filenameRadar      = filename + str(fff) + Radar + str(ff + 1) + ".mat"
            filenameTarget     = filename + str(fff) + Target + str(ff + 1) + ".mat"
            filenameData       = filename + str(fff) + Data + str(ff + 1) + ".mat"
            filenameTargetData = filename + str(fff) + TargetData + str(ff + 1) + ".mat"
            filenameNoiseData  = filename + str(fff) + NoiseData + str(ff + 1) + ".mat"
            filenameRTargetData = filename + str(fff) + RTargetData + str(ff + 1) + ".mat"
            filenameRNoiseData  = filename + str(fff) + RNoiseData + str(ff + 1) + ".mat"
            filenameLabel      = filename + str(fff) + Label + str(ff + 1) + ".mat"
            filenameSignal     = filename + str(fff) + Signal + str(ff + 1) + ".mat"

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

# 转换为np数组
def map_convert_to_numpy(address, data_index):
    mat_data = sio.loadmat(address)
    if data_index != "label":
        data = mat_data[data_index][0]  # "Maps" "RMapsT" "RMapsN" "" "" "label"
    else:
        data = mat_data[data_index]
    return data

def save_mat(name, data, filename='data.mat'):
    savemat(filename, {name: data})

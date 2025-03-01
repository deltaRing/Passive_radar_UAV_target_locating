import torch as t
import torch.nn
import torch.nn as nn
import torch.nn.functional as F

def mse_func(target, pred):
    return torch.nn.functional.mse_loss(pred, target)

def cross_entropy(target, pred):
    return torch.nn.functional.binary_cross_entropy_with_logits(pred, target)

def sigmoid_activation(target):
    return torch.nn.functional.sigmoid(target)

def inverse_sigmoid_mse_func(target, pred):
    pred   = 1 - pred # if pred --> target others --> 0
    target = torch.nn.functional.sigmoid(1e3 * target)
    return mse_func(target, pred)

def greater_mask(target, pred):
    target  = target - 0.75
    target  =  torch.nn.functional.sigmoid(1e3 * target)
    return cross_entropy(target, pred)
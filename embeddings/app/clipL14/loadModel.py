## This script downloads the clip model for embeddings service.

import torch
import torchvision.transforms as transforms
import clip

device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load('ViT-L/14', device)

#model.save('/code/app/clip-ViT-L-14.model')

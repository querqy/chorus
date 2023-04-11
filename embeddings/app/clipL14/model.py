import torch
import torchvision.transforms as transforms
import clip

device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load('ViT-L/14', device)

def get_text_sentence_embedding(text: str, normalize: bool = True):
    return model.encode_text(clip.tokenize(text))[0]



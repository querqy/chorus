#!/usr/bin/env python3
from sentence_transformers import SentenceTransformer
PATH_PRODUCTS_MODEL = "all-MiniLM-L6-v2"

query_text = "Sony Portable Bluetooth Speaker MBS-100 docking speaker 1.0 channels Black Sony"
model = SentenceTransformer(PATH_PRODUCTS_MODEL)
text_emb = model.encode(query_text)
print(text_emb)


#import torch
#import torchvision.transforms as transforms
#import clip

# Load the CLIP model
#device = "cuda" if torch.cuda.is_available() else "cpu"
#model, preprocess = clip.load('ViT-L/14', device)
#qry_text = "mobilephone"
#qry_encoding = model.encode_text(clip.tokenize(qry_text),normalize_embeddings=True, convert_to_numpy=True)
#print(qry_encoding)
#print (qry_encoding.shape)
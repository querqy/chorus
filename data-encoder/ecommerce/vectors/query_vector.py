#!/usr/bin/env python3
from sentence_transformers import SentenceTransformer
import torch
import clip
import requests
from PIL import Image

### This is a utility class to verify vectors generated from different models or
### run a sanity check on your generated vctors.

PATH_PRODUCTS_MODEL = "all-MiniLM-L6-v2"

def generate_text_embedding_minilm(textStr):
    model = SentenceTransformer(PATH_PRODUCTS_MODEL)
    text_emb = model.encode(textStr)
    #print(text_emb)
    #prints num dimensions
    #print (text_emb.shape)
    return(text_emb)

def generate_text_embedding_clip(textStr):
    # Load the CLIP model
    device = "cuda" if torch.cuda.is_available() else "cpu"
    model, preprocess = clip.load('ViT-L/14', device)
    qry_encoding = model.encode_text(clip.tokenize(textStr))
    #print(qry_encoding)
    #prints num dimensions
    #print (qry_encoding.shape)
    return(qry_encoding)

def generate_image_embedding_clip(imageUrl):
    # Load the CLIP model
    device = "cuda" if torch.cuda.is_available() else "cpu"
    model, preprocess = clip.load('ViT-L/14', device)
    try:
        r = requests.get(imageUrl, stream=True)
        # Load and preprocess the image
        validated_image = Image.open(r.raw)
        preprocess_image = preprocess(validated_image).unsqueeze(0).to(device)
        # Encode the image
        with torch.no_grad():
            image_encoding = model.encode_image(preprocess_image)[0]
            #print(image_encoding)
            #print (image_encoding.shape)
            return image_encoding
    except Exception:
        return []
    return(image_encoding)

def main():
    print("Text embedding (Minilm): " + str(generate_text_embedding_minilm("Sony Portable Bluetooth Speaker MBS-100 docking speaker 1.0 channels Black Sony")))
    print("Text embedding (Clip): " + str(generate_text_embedding_clip("mobilephone")))
    print("Image embedding (Clip): " + str(generate_image_embedding_clip("http://images.icecat.biz/img/gallery/img_3920564_high_1472618727_1208_7091.jpg")))

if __name__ == "__main__":
    main()
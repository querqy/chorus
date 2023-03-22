#!/usr/bin/env python3

import json
import io
import requests
from sentence_transformers import SentenceTransformer
from PIL import Image
from imgbeddings import imgbeddings
from transformers import CLIPTokenizer
import torch
import torchvision.transforms as transforms
import clip


# Currently you need to unzip the 4.json.zip file first.
PATH_PRODUCTS_DATASET = "data-encoder/ecommerce/vectors/data/1.json"
PATH_PRODUCTS_MODEL = "all-MiniLM-L6-v2"
PATH_PRODUCTS_VECTORS_JSON = "data-encoder/ecommerce/vectors/data/products-vectors-1.json"

# Load the CLIP model
device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load('ViT-L/14', device)

def load_products_dataset():
    # TODO, read in the files as .zip files so you don't have to unzip them yourself.
    with open(PATH_PRODUCTS_DATASET, "r") as infile:
        products_dataset = json.load(infile)
    return products_dataset


def get_product_sentence(model, product):
    #print(f"{(product['title'])} {(product['supplier'])}")
    return f"{(product['title'])} {(product['supplier'])}"
    #tokenizer = model._first_module().processor.tokenizer
    #product_sent = f"{(product['title'])}"
    #return truncate_sentence(product_sent, tokenizer)


def get_products_sentences(model, products_dataset):
    return [get_product_sentence(model, product) for product in products_dataset]


def get_product_image(product):
    product_img = f"{(product['img_high'])}"
    return product_img


def get_product_images(products_dataset):
    return [get_product_image(product) for product in products_dataset]


def load_products_embedding_model():
    return SentenceTransformer(PATH_PRODUCTS_MODEL)


def calculate_product_vector(model, product):
    product_sentence = get_product_sentence(product)
    return model.encode(product_sentence)


def calculate_products_vectors(model, products_dataset):
    products_sentences = get_products_sentences(model, products_dataset)
    return model.encode(products_sentences)

def calculate_product_image_vectors(product):
    try:
        image = get_product_image(product)
        r = requests.get(image, stream=True)
        # Load and preprocess the image
        validated_image = Image.open(r.raw)
        preprocess_image = preprocess(validated_image).unsqueeze(0).to(device)
        # Encode the image
        with torch.no_grad():
            image_encoding = model.encode_image(preprocess_image)
            #print(image_encoding)
            return image_encoding
    except Exception:
        return []


def calculate_product_image_vector(product):
    try:
        image = get_product_image(product)
        r = requests.get(image, stream=True)
        pImage = Image.open(io.BytesIO(r.content))
        ibed = imgbeddings()
        embedding = ibed.to_embeddings(pImage)
        return embedding[0][0:10]
    except Exception:
        print(image)
        return []

def calculate_image_vector(product_image):
    ibed = imgbeddings()
    embedding = ibed.to_embeddings(product_image)
    return embedding[0][0:10]


def calculate_products_image_vectors(products_dataset):
    products_images = [calculate_product_image_vector(product) for product in products_dataset]
    return products_images

def calculate_products_image_vectors_clip(products_dataset):
    products_images = [calculate_product_image_vectors(product) for product in products_dataset]
    return products_images

def export_products_json(products_dataset):
    # Serializing json
    json_object = json.dumps(products_dataset, indent=2)
    # Writing to sample.json
    with open(PATH_PRODUCTS_VECTORS_JSON, "w") as outfile:
        outfile.write(json_object)
    #with open(PATH_PRODUCTS_VECTORS_JSON, "w") as outfile:
    #    json.dumps(products_dataset, outfile, indent=2)

def truncate_sentence(sentence, tokenizer):
    """
    Truncate a sentence to fit the CLIP max token limit (77 tokens including the
    starting and ending tokens).

    Args:
        sentence(string): The sentence to truncate.
        tokenizer(CLIPTokenizer): Rretrained CLIP tokenizer.
    """

    cur_sentence = sentence
    #print("new doc",cur_sentence)
    tokens = tokenizer.encode(cur_sentence)

    if len(tokens) > 77:
        # Skip the starting token, only include 75 tokens
        truncated_tokens = tokens[1:76]
        cur_sentence = tokenizer.decode(truncated_tokens)
        # Recursive call here, because the encode(decode()) can have different result
        return truncate_sentence(cur_sentence, tokenizer)

    else:
        return cur_sentence

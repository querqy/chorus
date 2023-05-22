#!/usr/bin/env python3

import json
from PIL import Image
from transformers import CLIPTokenizer
import torch
import clip
import os
import numpy as np
#from transformers import CLIPProcessor, CLIPModel

images = None
PATH_PRODUCTS_DATASET = "data-encoder/fashion/vectors/data/"
NAME_DATASET = "6.json"

# Load the CLIP model
device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load('ViT-L/14', device)
#model = CLIPModel.from_pretrained("patrickjohncyh/fashion-clip")
#processor = CLIPProcessor.from_pretrained("patrickjohncyh/fashion-clip")


def load_products_dataset():
    # Read JSON file
    with open(PATH_PRODUCTS_DATASET+NAME_DATASET, 'r') as json_file:
        products_dataset = json.load(json_file)
    return products_dataset


def get_all_filenames(directory):
    """
    Returns a set of all filenames in the given directory.
    """
    filenames = set()
    for filename in os.listdir(directory):
        if os.path.isfile(os.path.join(directory, filename)):
            filenames.add(filename)
    return filenames


def check_image_exists(image_filename, images):
    """
    Checks if the desired filename exists within the filenames found in the given directory.
    Returns True if the filename exists, False otherwise.
    """
    if image_filename in images:
        #print(image_filename)
        return image_filename
    else:
        return np.nan


def get_product_sentence(product):
    sent = f"gender:{(product['gender'])} mastercategory:{(product['masterCategory'])} subcategory:{(product['subCategory'])} " \
           f"colour:{(product['baseColour'])} type: {(product['articleType'])} title:{(product['productDisplayName'])}"
    #print("get_product_sentence " + sent)
    return sent


def get_products_vectors(products_dataset):
    return [calculate_product_vector(product) for product in products_dataset]


def get_product_image(product,images):
    product_img = f"{(product['id'])}.jpg"
    img = check_image_exists(product_img,images)
    return img


def calculate_product_vector(product):
    product_sentence = get_product_sentence(product)
    return model.encode_text(clip.tokenize(product_sentence))[0]


def calculate_products_vectors(products_dataset):
    products_sentences = get_products_vectors(products_dataset)
    return products_sentences


def calculate_product_image_vectors(product, images):
    #print("in calculate_product_image_vectors")
    try:
        image = PATH_PRODUCTS_DATASET + "images/" + get_product_image(product, images)
        # Load and preprocess the image
        validated_image = Image.open(image)
        preprocess_image = preprocess(validated_image).unsqueeze(0).to(device)
        # Encode the image
        with torch.no_grad():
            image_encoding = model.encode_image(preprocess_image)[0]
            #print(image_encoding)
            return image_encoding
    except Exception:
        print("image exception"+ Exception)
        return []


def calculate_products_image_vectors_clip(products_dataset):
    global images
    images = get_all_filenames(PATH_PRODUCTS_DATASET + "images")
    #print(len(images))
    products_images = [calculate_product_image_vectors(product,images) for product in products_dataset]
    return products_images


def export_products_json(products_dataset):
    # Serializing json
    json_object = json.dumps(products_dataset, indent=2)
    # Writing to dataset.json
    with open(PATH_PRODUCTS_DATASET + "fashion-vectors-" + NAME_DATASET, "w") as outfile:
        outfile.write(json_object)


def truncate_sentence(sentence, tokenizer):
    """
    Truncate a sentence to fit the CLIP max token limit (77 tokens including the
    starting and ending tokens).

    Args:
        sentence(string): The sentence to truncate.
        tokenizer(CLIPTokenizer): Retrained CLIP tokenizer.
    """

    cur_sentence = sentence
    # print("new doc",cur_sentence)
    tokens = tokenizer.encode(cur_sentence)

    if len(tokens) > 77:
        # Skip the starting token, only include 75 tokens
        truncated_tokens = tokens[1:76]
        cur_sentence = tokenizer.decode(truncated_tokens)
        # Recursive call here, because the encode(decode()) can have different result
        return truncate_sentence(cur_sentence, tokenizer)

    else:
        return cur_sentence

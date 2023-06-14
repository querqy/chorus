#!/usr/bin/env python3

import json
import os
import requests
from zipfile import ZipFile

import finetuner

PATH_IMAGES = "data/images"


def load_products_dataset(input_file):
    with open(input_file) as dataFile:
        products_dataset = json.load(dataFile)
    return products_dataset


def get_product_sentence(product):
    return f"{(product['title'])} {(product['supplier'])}"


def get_products_sentences(products_dataset):
    return [get_product_sentence(product) for product in products_dataset]


def get_product_image(product):
    product_img = f"{(product['img_high'])}"
    return product_img


def calculate_products_vectors(model, products_dataset):
    products_sentences = get_products_sentences(products_dataset)

    return finetuner.encode(model=model, data=products_sentences)

def download_image(image_url):
    local_path = f"{PATH_IMAGES}/{image_url.split('/')[-1]}"

    if os.path.isfile(local_path):
        return local_path

    response = requests.get(image_url)
    if response.status_code != 200:
        return image_url
    img_data = response.content

    with open(local_path, 'wb') as handler:
        handler.write(img_data)

    return local_path


def calculate_products_image_vectors_clip(model, products_dataset):
    result = []
    for product in products_dataset:
        try:
            image_url = get_product_image(product)
            local_url = download_image(image_url)
            if local_url != image_url:
                result.append(finetuner.encode(model=model, data=[local_url])[0])
            else:
                result.append([])
        except:
            result.append([])


    return result


def export_products_json(products_dataset, output_file):
    # Serializing json
    json_object = json.dumps(products_dataset, indent=2)
    # Writing to dataset.json
    with open(output_file, "w") as outfile:
        outfile.write(json_object)
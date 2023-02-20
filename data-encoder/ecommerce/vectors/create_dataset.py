#!/usr/bin/env python3

from sentence_transformers import SentenceTransformer, util
import products

model_img = SentenceTransformer('clip-ViT-L-14')
model_txt = SentenceTransformer('all-MiniLM-L6-v2')

#### Load the original products dataset
products_dataset = products.load_products_dataset()

#### Use the embedding model to calculate vectors for all products
products_vectors = products.calculate_products_vectors(model_txt, products_dataset)

#### Use the embedding model to calculate image vectors for all products
#products_image_vectors = products.calculate_products_image_vectors(products_dataset)
products_image_vectors = products.calculate_products_image_vectors_clip(model_img, products_dataset)

#### Create the new products dataset by creating a new field with the embedding vector
for idx in range(len(products_dataset)):
    try:
        products_dataset[idx]["product_vector"] = products_vectors[idx].tolist()
        products_dataset[idx]["product_image_vector"] = products_image_vectors[idx].tolist()
    except Exception:
        print('AttributeError')
        print(products_image_vectors[idx])


#### Export the new products dataset for all formats
products.export_products_json(products_dataset)

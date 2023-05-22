#!/usr/bin/env python3

import products

err_msg = "Image not resolved for id : "
PATH_PRODUCTS_DATASET = "data-encoder/fashion/vectors/data/"

#### Load the original products dataset
products_dataset = products.load_products_dataset()

#### Load images from directory
images = products.get_all_filenames(PATH_PRODUCTS_DATASET + "images")

#### Use the embedding model to calculate vectors for all products
products_vectors = products.calculate_products_vectors(products_dataset)

#### Use the embedding model to calculate image vectors for all products
products_image_vectors = products.calculate_products_image_vectors_clip(products_dataset)

#### Create the new products dataset by creating a new field with the embedding vector
for idx in range(len(products_dataset)):
    try:
        products_dataset[idx]["image"] = "/images/"+ products_dataset[idx]["id"]+".jpg"
        products_dataset[idx]["product_vector"] = products_vectors[idx].tolist()
        products_dataset[idx]["product_image_vector"] = products_image_vectors[idx].tolist()
    except Exception:
        print("Exception "+Exception)
        print(f'{err_msg}{products_dataset[idx][0]}')


#### Export the new products dataset for all formats
products.export_products_json(products_dataset)

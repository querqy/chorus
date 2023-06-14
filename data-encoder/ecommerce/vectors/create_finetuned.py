#!/usr/bin/env python3

import finetuned_products as products
import finetuner

DEVICE = 'cpu'

model_img = finetuner.get_model('jinaai/ecommerce-clip-model', select_model='clip-vision', device=DEVICE)
model_txt = finetuner.get_model('jinaai/ecommerce-sbert-model', device=DEVICE)

for index in range(1, 5):
    #### Load the original products dataset
    products_dataset = products.load_products_dataset(f"data/products-vectors-{index}.json")

    #### Use the embedding model to calculate vectors for all products
    products_vectors = products.calculate_products_vectors(model_txt, products_dataset)

    #### Use the embedding model to calculate image vectors for all products
    products_image_vectors = products.calculate_products_image_vectors_clip(model_img, products_dataset)

    #### Create the new products dataset by creating a new field with the embedding vector
    for idx in range(len(products_dataset)):
        try:
            products_dataset[idx]["finetuned_product_vector"] = products_vectors[idx].tolist()
            products_dataset[idx]["finetuned_image_vector"] = products_image_vectors[idx].tolist()
        except Exception:
            print(f'{products_dataset[idx]["id"]}')


    #### Export the new products dataset for all formats
    output_file = f"data/finetuned-products-vectors-{index}.json"
    products.export_products_json(products_dataset, output_file)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Data Encoder
==========================
*This page provides details about the `data-encoder` module*

# Icecat Data Details

The Chorus project includes some public, sample datasets. These datasets enables the community to learn, experiment and collaborate in a safe manner and are a key part of demonstrating how to build measurable and tunable ecommerce search, with open source components.

The sample product data is generously sourced from [Icecat](https://icecat.biz/) and is licensed under their [Open Content License](https://iceclog.com/open-content-license-opl/).

The version of the Icecat product data that Chorus [provides](https://querqy.org/datasets/icecat/icecat-products-w_price-19k-20201127.tar.gz) has the following changes:
* Data converted to JSON format.
* Products that don't have a 500x500 pixel image listed are removed.
* The Prices of ~19,000 products got extracted from the https://www.upcitemdb.com/ service, using EAN codes.

# Data Encoder Process

Icecat is a large product information database that contains detailed information about various products, such as electronics, home appliances, software, and more. The Icecat dataset is a structured collection of this product information that is made available for use by businesses, researchers, and other organizations.

The Icecat dataset contains product descriptions, specifications, images, and other relevant information for thousands of products. This information is standardized and organized into a consistent format, which makes it easy to use for various purposes such as price comparisons, product recommendations, etc.

However, it can be challenging to work with different types of products and their attributes. Hence, for simplicity, in the data encoding process we will focus on `title` and `brand` fields for generating the *text encoding* and `img_high` field to generate image encoding.
As for another simplification the data has been split into 4 chunks, the 4 json-zips can be found in `data` folder.

A Python utility has been developed that can generate and augment the Icecat dataset with text and image encoding using two main scripts: `create_dataset.py` and `products.py`.

The `create_dataset.py` script is the main script that processes the dataset and adds the text vectors into the text vector field `product_vector` and image vectors into the image vector field `product_image_vector` into the dataset. The script delivers the vectorised product information as `products-vectors-<<dataset>>.json`.

The `products.py` script is a helper script with all the utility methods to extract desired fields of our interests from the dataset, render text and image encoding and allows users to configure the transformers to be used for encoding and can be customized to fit different needs.

Currently, the encoding process uses the [CLIP](https://github.com/openai/CLIP) model from OpenAI to generate *image encoding* and renders a 768 dimensional encoding. For *text encoding* [MiniLM](https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2) has been used which renders a 384 dimensional encoding.

To run the encoding process, please verify the model and file zip config, followed by:
```
python data-encoder/ecommerce/vectors/create_dataset.py
```

The utility is easy to use and can be customized to work with different structured dataset or different fields from the Icecat dataset.

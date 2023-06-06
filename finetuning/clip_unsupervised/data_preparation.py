import json
import click
from tqdm import tqdm
from zipfile import ZipFile

from docarray import Document, DocumentArray


def prepare_training_data(filepaths: list[str]) -> dict[str, str]:
    dataset = DocumentArray()
    for filepath in filepaths:
        with ZipFile(filepath, 'r') as archive:
            for filename in archive.namelist():
                with archive.open(filename, 'r') as f:
                    objs = json.load(f)
                    for obj in tqdm(objs, desc=f'Load data from "{filename}"'):
                        title = obj.get('title', '')
                        supplier = obj.get('supplier', '')
                        product_type = obj.get('attr_t_product_type')
                        if 'img_500x500' in obj:
                            if not title and supplier:
                                continue
                            else:
                                text_value = (
                                    f'{title} {supplier} {product_type}'
                                    if product_type
                                    else f'{title} {supplier}'
                                )
                            try:
                                img_doc = Document(
                                    uri=obj.get('img_500x500')
                                ).load_uri_to_blob()
                                text_doc = Document(text=text_value)
                                dataset.append(
                                    Document(chunks=DocumentArray([text_doc, img_doc]))
                                )
                            except:
                                pass
    return dataset


@click.command()
@click.option(
    '--input',
    '-i',
    default=[
        '../data-encoder/ecommerce/vectors/data/1.json.zip',
        '../data-encoder/ecommerce/vectors/data/2.json.zip',
        '../data-encoder/ecommerce/vectors/data/3.json.zip',
        '../data-encoder/ecommerce/vectors/data/4.json.zip',
    ],
    multiple=True,
    help='Input filepaths',
)
def main(input):
    train_dataset = prepare_training_data(input)
    train_dataset.summary()
    train_dataset.save_binary('clip_unsupervised/clip_train_dataset.da')


if __name__ == '__main__':
    main()

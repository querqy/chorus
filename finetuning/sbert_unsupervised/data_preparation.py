import json
import click
from zipfile import ZipFile

from typing import List

from docarray import Document, DocumentArray

QUERIES_DA_PATH = 'sbert_unsupervised/queries.da'
CORPUS_DA_PATH = 'sbert_unsupervised/corpus.da'


def load_queries(filename: str) -> List[str]:
    """Loads queries from a jsonl file."""
    queries = list()
    with open(filename, 'r') as f:
        for i, line in enumerate(f):
            obj = json.loads(line)
            queries.append(obj['text'])
    return queries


def load_corpus(filepaths: List[str]) -> List[str]:
    """Loads corpus from a list of zipped jsonl files with product properties.
    For the training, we only consider the properties `title` and `supplier`.
    """
    corpus = list()
    for filepath in filepaths:
        with ZipFile(filepath, 'r') as archive:
            for filename in archive.namelist():
                with archive.open(filename, 'r') as f:
                    objs = json.load(f)
                    for obj in objs:
                        title = obj.get('title', '')
                        supplier = obj.get('supplier', '')
                        if title and supplier:
                            corpus.append(f'{title} {supplier}')
    return corpus


def prepare_queries(queries: List[str]) -> DocumentArray:
    """Transforms queries into Finetuner's dataset format (DocumentArray)."""
    return DocumentArray([Document(text=q) for q in queries])


def prepare_corpus(corpus: List[str]) -> DocumentArray:
    """Transforms product data into Finetuner's dataset format (DocumentArray)."""
    return DocumentArray([Document(text=p) for p in corpus])


@click.command()
@click.option(
    '--queries',
    default='sbert_unsupervised/generated-queries.jsonl',
    help='Path to queries file',
)
@click.option(
    '--corpus',
    default=[
        '../data-encoder/ecommerce/vectors/data/1.json.zip',
        '../data-encoder/ecommerce/vectors/data/2.json.zip',
        '../data-encoder/ecommerce/vectors/data/3.json.zip',
        '../data-encoder/ecommerce/vectors/data/4.json.zip',
    ],
    help='Path to corpus files',
    multiple=True,
)
def main(queries: str, corpus: str):
    queries = load_queries(queries)
    corpus = load_corpus(corpus)
    queries = prepare_queries(queries)
    corpus = prepare_corpus(corpus)
    queries.summary()
    corpus.summary()
    queries.save_binary(QUERIES_DA_PATH)
    corpus.save_binary(CORPUS_DA_PATH)
    print(
        f'Prepared queries and corpus for unsupervised training of SBERT model:',
        f'{QUERIES_DA_PATH}, {CORPUS_DA_PATH}',
    )


if __name__ == '__main__':
    main()

from sentence_transformers import SentenceTransformer

model = SentenceTransformer('all-MiniLM-L12-v2.model')


def get_text_sentence_embedding(text: str, normalize: bool = True):
    return model.encode(text, normalize_embeddings=normalize, convert_to_numpy=True)



from sentence_transformers import SentenceTransformer

model = SentenceTransformer('clip-ViT-L-14')


def get_text_sentence_embedding(text: str, normalize: bool = True):
    return model.encode(text, normalize_embeddings=normalize, convert_to_numpy=True)




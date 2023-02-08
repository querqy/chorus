## This script downloads the minilm model for embeddings service.

from sentence_transformers import SentenceTransformer

model = SentenceTransformer('all-MiniLM-L12-v2')
model.save('embeddings/app/all-MiniLM-L12-v2.model')
#!/usr/bin/env python3
from sentence_transformers import SentenceTransformer
PATH_PRODUCTS_MODEL = "all-MiniLM-L6-v2"

query_text = "Sony Portable Bluetooth Speaker MBS-100 docking speaker 1.0 channels Black Sony"
model = SentenceTransformer(PATH_PRODUCTS_MODEL)
text_emb = model.encode(query_text)
print(text_emb)
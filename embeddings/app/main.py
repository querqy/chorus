from fastapi import FastAPI
from clipL14 import router as router_clip
from minilm import router as router_minilm
from finetuned import router as router_finetuned
from openai_compat import router as router_openai

app = FastAPI()

app.include_router(router_clip.router, prefix="/clip")
app.include_router(router_minilm.router, prefix="/minilm")
app.include_router(router_finetuned.sbert_router, prefix="/ftbert")
app.include_router(router_finetuned.clip_router, prefix="/ftclip")
app.include_router(router_openai.router, prefix="/v1")

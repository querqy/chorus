from fastapi import FastAPI
from clipL14 import router as router_clip
from minilm import router as router_minilm

app = FastAPI()

app.include_router(router_clip.router, prefix="/clip")
app.include_router(router_minilm.router, prefix="/minilm")



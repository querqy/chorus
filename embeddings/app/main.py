from fastapi import FastAPI
from strans import router as router_strans

app = FastAPI()

app.include_router(router_strans.router, prefix="/strans")



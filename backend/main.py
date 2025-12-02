from fastapi import FastAPI
from auth.google_router import router as google_router
from api.user import router as user_router
import auth.firebase_init
from dotenv import load_dotenv
load_dotenv()

app = FastAPI()

app.include_router(google_router)
app.include_router(user_router)


@app.get("/")
def root():
    return {"status": "OK"}
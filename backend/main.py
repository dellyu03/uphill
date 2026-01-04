from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from auth.google_router import router as google_router
from api.user import router as user_router
from api.routines import router as routines_router
import auth.firebase_init  
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

# TODO: 배포 환경에서는 허용 origin 을 실제 앱 도메인 / IP 로 제한
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(google_router)
app.include_router(user_router)
app.include_router(routines_router)


@app.get("/")
def root():
    return {"status": "OK"}
from fastapi import FastAPI

from api import routines

app = FastAPI(title="Uphill Backend")


@app.get("/")
def read_root():
    return {"message": "Hello, World!"}


app.include_router(routines.router)

    
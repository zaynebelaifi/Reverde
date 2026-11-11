from datetime import datetime, timezone
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
app=FastAPI(title="Analytics Service API",version="1.0.0")
app.add_middleware(CORSMiddleware,allow_origins=["http://localhost:3000","http://localhost:5173"],allow_credentials=True,allow_methods=["*"],allow_headers=["*"])
@app.get("/hello")
def hello()->dict:return {"service":"analytics-service","status":"UP","message":"Hello from analytics-service","port":8090,"timestamp":datetime.now(timezone.utc).isoformat()}
@app.get("/health")
def health()->dict:return {"status":"UP"}

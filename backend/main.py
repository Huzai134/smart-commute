from fastapi import FastAPI, UploadFile, File, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, Optional
from dotenv import load_dotenv
import google.generativeai as genai
import uuid
import os
import io
import math
from PIL import Image
import json
import asyncio

load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

app = FastAPI(title="Smart Commute API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==========================================
# 🚀 NEW: AUTHENTICATION & USERS
# ==========================================
class UserRegister(BaseModel):
    phone_number: str
    full_name: str
    password: str

class UserLogin(BaseModel):
    phone_number: str
    password: str

# Mock Database for Users
users_db = {
    # Pre-loaded mock user
    "03001234567": {"id": "test_user_001", "full_name": "Muhammad Huzaifa", "password": "password123", "trust_level": "Gold"}
}

@app.post("/auth/register/")
def register_user(user: UserRegister):
    if user.phone_number in users_db:
        raise HTTPException(status_code=400, detail="Phone number already registered")
    
    new_id = str(uuid.uuid4())
    users_db[user.phone_number] = {
        "id": new_id,
        "full_name": user.full_name,
        "password": user.password, # In production, hash this!
        "trust_level": "Unverified"
    }
    return {"message": "Registration successful", "user_id": new_id, "full_name": user.full_name}

@app.post("/auth/login/")
def login_user(user: UserLogin):
    db_user = users_db.get(user.phone_number)
    if not db_user or db_user["password"] != user.password:
        raise HTTPException(status_code=401, detail="Invalid phone number or password")
    
    return {
        "message": "Login successful", 
        "user_id": db_user["id"], 
        "full_name": db_user["full_name"],
        "trust_level": db_user["trust_level"]
    }

# ==========================================
# ROUTES & METERING
# ==========================================
class RouteCreate(BaseModel):
    user_id: str
    start_location: str
    end_location: str
    is_active: bool = False
    engine_cc: int = 1000

class LiveRideData(BaseModel):
    engine_cc: int
    actual_distance_km: float

LOCATION_DB = {
    "Saddar Metro Station, Rawalpindi": (33.5955, 73.0538),
    "Bahria Town Phase 7, Rawalpindi": (33.5280, 73.0984),
    "Commercial Market, Satellite Town, Rawalpindi": (33.6366, 73.0732),
    "National University of Modern Languages (NUML), H-9, Islamabad": (33.6528, 73.0336),
    "GCT College, Peshawar Road, Rawalpindi": (33.6062, 73.0153)
}

def calculate_real_distance(start_str: str, end_str: str) -> float:
    lat1, lon1 = LOCATION_DB.get(start_str, (33.6000, 73.0500))
    lat2, lon2 = LOCATION_DB.get(end_str, (33.6500, 73.0200))
    R = 6371.0 
    a = math.sin(math.radians(lat2 - lat1) / 2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(math.radians(lon2 - lon1) / 2)**2
    return round((R * (2 * math.atan2(math.sqrt(a), math.sqrt(1 - a)))) * 1.3, 1)

def calculate_suggested_price(cc: int, distance: float):
    avg = 18 if cc <= 800 else 15 if cc <= 1000 else 12 if cc <= 1300 else 10
    return round(((distance / avg) * 280) / 2, 0)

routes_db = [
    {"route_id": "mock_1", "user_id": "driver_ali", "start_location": "Bahria Town Phase 7, Rawalpindi", "end_location": "National University of Modern Languages (NUML), H-9, Islamabad", "is_active": True, "engine_cc": 1300, "distance_km": 19.5, "suggested_price": 228.0},
    {"route_id": "mock_2", "user_id": "driver_sara", "start_location": "Commercial Market, Satellite Town, Rawalpindi", "end_location": "GCT College, Peshawar Road, Rawalpindi", "is_active": True, "engine_cc": 800, "distance_km": 8.2, "suggested_price": 64.0}
]

@app.post("/routes/")
def create_route(route: RouteCreate):
    new_route = route.model_dump()
    new_route["route_id"] = str(uuid.uuid4())
    exact_dist = calculate_real_distance(route.start_location, route.end_location)
    new_route.update({"distance_km": exact_dist, "suggested_price": calculate_suggested_price(route.engine_cc, exact_dist)})
    routes_db.append(new_route)
    return {"message": "Route saved", "route": new_route}

@app.get("/routes/active/")
def get_active_routes(): return {"active_carpools": [r for r in routes_db if r["is_active"]]}

@app.get("/routes/match/{user_id}")
def get_smart_matches(user_id: str):
    user_route = next((r for r in routes_db if r["user_id"] == user_id and r["is_active"]), None)
    if not user_route: return {"error": "No active route."}
    others = [r for r in routes_db if r["user_id"] != user_id and r["is_active"]]
    try:
        model = next((m.name for m in genai.list_models() if 'generateContent' in m.supported_generation_methods), None)
        return {"ai_analysis": genai.GenerativeModel(model).generate_content(f"User: {user_route['start_location']} to {user_route['end_location']}. Others: {others}. Who to carpool with in Rawalpindi?").text}
    except Exception as e: return {"error": str(e)}

@app.post("/routes/meter/")
def calculate_metered_price(data: LiveRideData): return {"status": "success", "final_distance": round(data.actual_distance_km, 2), "final_price": calculate_suggested_price(data.engine_cc, data.actual_distance_km)}

# ==========================================
# WEBSOCKET CHAT & AI VISION
# ==========================================
class ConnectionManager:
    def __init__(self): self.active_connections: Dict[str, WebSocket] = {}
    async def connect(self, websocket: WebSocket, user_id: str): await websocket.accept(); self.active_connections[user_id] = websocket
    def disconnect(self, user_id: str): self.active_connections.pop(user_id, None)
    async def send_personal_message(self, message: str, sender_id: str, receiver_id: str):
        if receiver_id in self.active_connections: await self.active_connections[receiver_id].send_text(json.dumps({"sender_id": sender_id, "message": message}))

chat_manager = ConnectionManager()

@app.websocket("/ws/chat/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: str):
    await chat_manager.connect(websocket, user_id)
    try:
        while True:
            data = json.loads(await websocket.receive_text())
            receiver_id, text = data.get("receiver_id"), data.get("message")
            if receiver_id and text:
                await chat_manager.send_personal_message(text, user_id, receiver_id)
                await asyncio.sleep(1.5)
                await chat_manager.send_personal_message(f"Copy that. (Auto-reply from {receiver_id})", receiver_id, user_id)
    except WebSocketDisconnect: chat_manager.disconnect(user_id)

@app.post("/users/verify/")
async def verify_id_card(file: UploadFile = File(...)):
    try:
        image = Image.open(io.BytesIO(await file.read()))
        for model in ['gemini-1.5-flash', 'gemini-1.5-pro', 'gemini-pro-vision']:
            try: return json.loads(genai.GenerativeModel(model).generate_content(['Is this a valid ID? JSON ONLY: {"is_valid": true, "name": "name", "id": "id", "reason": "reason"}', image]).text.replace('```json', '').replace('```', '').strip())
            except Exception: continue 
        return {"is_valid": False, "reason": "API Key blocked Vision."}
    except Exception as e: return {"is_valid": False, "reason": str(e)}
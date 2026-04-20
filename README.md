# 🚕 Smart Commute: AI-Powered University Carpooling

**Smart Commute** is a full-stack, GPS-tracked ride-sharing platform designed specifically for university students and employees. 

Standard carpooling is fundamentally flawed: if a driver travels 15km, but a passenger only rides along for 4km, the passenger usually ends up splitting the cost of the *entire* trip. I built Smart Commute to solve this. Using real-time phone GPS hardware and dynamic backend mathematics, this app acts like a live taxi meter—ensuring passengers only ever pay for the exact distance they travel, while keeping the platform secure using AI-driven ID verification.

---

## 🧠 The Logic: How It Actually Works

This app isn't just a basic CRUD application; it relies on mathematical routing, live hardware tracking, and AI to function.

### 1. The "Fair Share" Fuel Algorithm
Instead of static pricing, the app dynamically calculates fuel costs based on real-world physics and current economics.
* **The Math:** The user selects their vehicle's Engine Capacity (e.g., 800cc, 1000cc). The backend knows that an 800cc car averages 18km/liter, while an 1800cc car averages 10km/liter.
* **The Formula:** `((Exact Distance / Vehicle Mileage) * Current Fuel Price) / 2`
* **The Result:** The cost is split perfectly in half between the driver and passenger, calculated down to the exact Rupee.

### 2. Live GPS Metering (No Google Maps API Required)
To avoid the massive costs of the Google Maps API, I built a custom Geocoding and Routing Engine.
* **Hardware Tracking:** The Flutter app taps directly into the phone's native location sensors (`geolocator`) to grab exact latitude/longitude when the passenger clicks "Start Ride" and "End Ride."
* **The Haversine Formula:** The Python backend takes these two GPS coordinates and uses the Haversine mathematical formula to calculate the exact direct distance across the curve of the Earth.
* **Urban Routing Factor:** Because roads aren't straight lines, the backend multiplies the Haversine result by `1.3` to accurately account for urban turns and curves in the Rawalpindi/Islamabad area.

### 3. Real-Time WebSockets Chat
Negotiating a pickup spot requires instant communication. Instead of using standard REST APIs (which require refreshing the page), I implemented a **WebSocket** architecture. The Python server holds a persistent open pipeline to the Flutter app, allowing drivers and passengers to text each other in real-time with zero latency.

### 4. AI Matchmaker & Security (Google Gemini)
* **Smart Dispatching:** The app feeds the active daily routes into the Gemini AI, which acts as a dispatcher. It analyzes overlapping routes (e.g., Bahria Town to NUML) and suggests the most logical carpool matches.
* **Vision ID Verification:** To build a "Trust Level" system, users upload their University or Employee ID card. The backend uses Gemini 1.5 Vision to scan the image, extract the text, and verify if it is a legitimate organizational ID before granting a "Verified Gold" badge.

---

## 🛠️ The Tech Stack

### Frontend (Mobile App)
* **Framework:** Flutter (Dart)
* **State Management:** Provider
* **Maps:** `flutter_map` natively rendering OpenStreetMap (OSM) tiles for a completely free map UI.
* **Hardware:** `geolocator` for native GPS tracking.
* **Communication:** `web_socket_channel` for live chat.
* **Local Storage:** `shared_preferences` for persistent secure session logins.

### Backend (Server & AI)
* **Framework:** Python with FastAPI (chosen for its asynchronous speed).
* **Server:** Uvicorn.
* **WebSockets:** Built-in FastAPI WebSocket managers for real-time routing.
* **AI Integration:** Google Generative AI (`google-generativeai`) API for text and vision processing.

---

## 🚀 How to Run the Project Locally

### 1. Start the Python Backend
Ensure you have Python 3.9+ installed.
```bash
cd backend
python -m venv .venv
# Activate the virtual environment (Windows)
.\.venv\Scripts\activate
# Install requirements
pip install fastapi uvicorn google-generativeai python-dotenv pydantic pillow python-multipart websockets
# Run the server
uvicorn main:app --reload

## 👨‍💻 Developed By

**Muhammad Huzaifa Farooqui** * **GitHub:** [@Huzai134](https://github.com/Huzai134)
* **Email:** numl-f23-58547@numls.edu.pk
* **Institution:** National University of Modern Languages (NUML)

*Built as an MVP to demonstrate Full-Stack engineering, AI integration, and live hardware routing.*
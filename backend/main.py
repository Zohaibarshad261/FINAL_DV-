"""
DermaVision+ — FastAPI backend
Handles: /predict (PyTorch EfficientNet-B0), /chat, /translate, /doctors, /health
Run: uvicorn main:app --host 0.0.0.0 --port 8000
"""

import csv
import hashlib
import html
import io
import json
import os
from contextlib import asynccontextmanager
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()  # reads backend/.env into os.environ
from typing import Any, Optional

import torch
import torch.nn.functional as F
from deep_translator import GoogleTranslator
from efficientnet_pytorch import EfficientNet
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from geopy.distance import geodesic
from openai import OpenAI
from PIL import Image
from pydantic import BaseModel
from torchvision import transforms

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

MODEL_PATH = os.getenv("MODEL_PATH", "best_efficientnet.pth")
TOP_K = 5
DATA_DIR = Path(__file__).parent / "data"
DOCTORS_CSV_PATH = DATA_DIR / "final_cleansed_data.csv"
CITY_COORDS_PATH = DATA_DIR / "pk_city_coords.json"

CLASS_NAMES = [
    "Acne", "Actinic_Keratosis", "Benign_tumors", "Bullous", "Candidiasis",
    "DrugEruption", "Eczema", "Infestations_Bites", "Lichen", "Lupus",
    "Moles", "Psoriasis", "Rosacea", "Seborrh_Keratoses", "SkinCancer",
    "Sun_Sunlight_Damage", "Tinea", "Unknown_Normal", "Vascular_Tumors",
    "Vasculitis", "Vitiligo", "Warts",
]

DISEASE_INFO: dict[str, dict[str, str]] = {
    "Acne": {
        "symptoms": "Pimples, blackheads, whiteheads, oily skin, nodules, cysts",
        "precautions": "Keep skin clean, avoid touching face, use non-comedogenic products, stay hydrated",
    },
    "Actinic_Keratosis": {
        "symptoms": "Rough scaly patch, flat to slightly raised, itching or burning, hardened wart-like surface",
        "precautions": "Use sunscreen daily, wear protective clothing, avoid peak sun hours, regular dermatologist check-ups",
    },
    "Benign_tumors": {
        "symptoms": "Painless lump, slow growth, well-defined borders, soft to firm texture",
        "precautions": "Monitor for changes, avoid trauma to area, consult dermatologist regularly",
    },
    "Bullous": {
        "symptoms": "Fluid-filled blisters, itching, burning sensation, skin tenderness",
        "precautions": "Keep blisters clean, avoid bursting blisters, use prescribed medication, wear loose clothing",
    },
    "Candidiasis": {
        "symptoms": "Red rash, itching, white patches, burning sensation, skin folds affected",
        "precautions": "Keep skin dry, wear breathable clothing, maintain good hygiene, avoid excessive sugar intake",
    },
    "DrugEruption": {
        "symptoms": "Red rash, hives, itching, blistering, fever",
        "precautions": "Stop the triggering medication, consult doctor immediately, avoid self-medication, carry allergy list",
    },
    "Eczema": {
        "symptoms": "Dry skin, redness, intense itching, rash, skin thickening, fluid-filled bumps",
        "precautions": "Moisturize regularly, avoid scratching, identify and avoid triggers, use gentle soap",
    },
    "Infestations_Bites": {
        "symptoms": "Itching, red bumps, blisters, swelling, visible burrows",
        "precautions": "Keep environment clean, use repellents, wash bedding regularly, avoid contact with infected persons",
    },
    "Lichen": {
        "symptoms": "Purple-red bumps, itching, flat-topped lesions, lacy white patches in mouth",
        "precautions": "Manage stress, avoid certain medications, consult dermatologist, practice good oral hygiene",
    },
    "Lupus": {
        "symptoms": "Butterfly rash on face, joint pain, fatigue, photosensitivity, hair loss",
        "precautions": "Use sunscreen, avoid sun exposure, rest adequately, follow prescribed medication",
    },
    "Moles": {
        "symptoms": "Dark round spots, uniform color, raised or flat, may have hair",
        "precautions": "Monitor for ABCDE changes, use sunscreen, avoid tanning beds, annual skin check",
    },
    "Psoriasis": {
        "symptoms": "Thick red patches, silvery scales, dry cracked skin, itching, burning",
        "precautions": "Keep skin moisturized, avoid triggers, manage stress, follow prescribed treatment",
    },
    "Rosacea": {
        "symptoms": "Persistent redness on face, visible blood vessels, swollen red bumps, eye irritation",
        "precautions": "Use gentle skincare, avoid spicy food, limit alcohol, use SPF 30+ sunscreen daily",
    },
    "Seborrh_Keratoses": {
        "symptoms": "Waxy brown growths, stuck-on appearance, itching, varied size",
        "precautions": "Monitor for changes, avoid irritating lesion, consult dermatologist if concerned",
    },
    "SkinCancer": {
        "symptoms": "New growth, changing mole, non-healing sore, pink pearly bump, reddish patch",
        "precautions": "Immediate dermatologist consultation, use sunscreen, avoid tanning beds, regular self-exam",
    },
    "Sun_Sunlight_Damage": {
        "symptoms": "Sunburn, dark spots, wrinkles, freckles, rough texture, discoloration",
        "precautions": "Apply sunscreen daily, seek shade, wear protective clothing and hats, avoid peak sun hours",
    },
    "Tinea": {
        "symptoms": "Ring-shaped rash, itching, scaly skin, redness, hair loss (scalp type)",
        "precautions": "Keep skin dry, avoid sharing personal items, use antifungal treatment, wear breathable footwear",
    },
    "Unknown_Normal": {
        "symptoms": "No significant skin abnormalities detected",
        "precautions": "Maintain good skin hygiene, use sunscreen, stay hydrated, moisturize regularly",
    },
    "Vascular_Tumors": {
        "symptoms": "Red or purple growth, soft compressible mass, may bleed easily, skin discoloration",
        "precautions": "Avoid trauma to area, monitor for changes, consult dermatologist, protect from injury",
    },
    "Vasculitis": {
        "symptoms": "Palpable purpura, red spots, skin ulcers, joint pain, fatigue",
        "precautions": "Follow prescribed medication, avoid smoking, monitor kidney function, reduce infection risk",
    },
    "Vitiligo": {
        "symptoms": "White patches on skin, premature graying of hair, loss of color in mucous membranes",
        "precautions": "Use high-SPF sunscreen on white patches, wear protective clothing, consult dermatologist",
    },
    "Warts": {
        "symptoms": "Rough bumpy growth, cauliflower-like texture, black dots, pain when pressed",
        "precautions": "Avoid touching warts, keep area clean, do not share personal items, avoid walking barefoot",
    },
}

# ---------------------------------------------------------------------------
# Model + preprocessing (loaded once at startup)
# ---------------------------------------------------------------------------

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
_model: Optional[EfficientNet] = None

_transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    # Normalization exactly matching training (cell-27 in notebook)
    transforms.Normalize(mean=[0.485, 0.485, 0.485], std=[0.229, 0.229, 0.229]),
])


def _load_model() -> EfficientNet:
    m = EfficientNet.from_name("efficientnet-b0", num_classes=22)
    state = torch.load(MODEL_PATH, map_location=device)
    m.load_state_dict(state)
    m.to(device)
    m.eval()
    return m


# ---------------------------------------------------------------------------
# App lifecycle
# ---------------------------------------------------------------------------

@asynccontextmanager
async def lifespan(app: FastAPI):
    global _model
    if not os.path.exists(MODEL_PATH):
        raise RuntimeError(
            f"Model file not found: {MODEL_PATH}\n"
            "Copy best_efficientnet.pth into the backend/ folder (or set MODEL_PATH env var)."
        )
    _model = _load_model()
    print(f"[DermaVision+] Model loaded on {device}  ✓")
    yield


app = FastAPI(title="DermaVision+ API", version="2.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# /health
# ---------------------------------------------------------------------------

@app.get("/health")
async def health() -> dict[str, str]:
    return {
        "status": "ok",
        "device": str(device),
        "openai_key": "set" if os.environ.get("OPENAI_API_KEY") else "MISSING",
    }


# ---------------------------------------------------------------------------
# /predict  — PyTorch EfficientNet-B0 inference
# ---------------------------------------------------------------------------

@app.post("/predict")
async def predict(
    image: UploadFile = File(...),
    user_id: str = Form(default=""),
) -> dict[str, Any]:
    if _model is None:
        raise HTTPException(status_code=503, detail="Model not loaded yet")

    try:
        raw = await image.read()
        img = Image.open(io.BytesIO(raw)).convert("RGB")
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Cannot read image: {exc}")

    tensor = _transform(img).unsqueeze(0).to(device)

    with torch.no_grad():
        logits = _model(tensor)
        probs = F.softmax(logits, dim=1)[0].cpu().tolist()

    ranked = sorted(range(len(probs)), key=lambda i: probs[i], reverse=True)

    top_k = [
        {"label": CLASS_NAMES[i], "confidence": round(probs[i] * 100, 2)}
        for i in ranked[:TOP_K]
    ]

    best_idx = ranked[0]
    disease = CLASS_NAMES[best_idx]
    confidence = round(probs[best_idx] * 100, 2)
    info = DISEASE_INFO.get(disease, {"symptoms": "", "precautions": ""})

    return {
        "disease": disease,
        "confidence": confidence,
        "symptoms": info["symptoms"],
        "precautions": info["precautions"],
        "topPredictions": top_k,   # Flutter ResultScreen reads this key
        "top_k": top_k,            # alias for convenience
    }


# ---------------------------------------------------------------------------
# /chat  — OpenAI chatbot
# ---------------------------------------------------------------------------

class ChatRequest(BaseModel):
    message: str
    disease_context: str = ""
    language: str = "en"


_SYSTEM_PROMPT = (
    "You are DermaBot, an expert dermatology assistant. "
    "Provide clear, empathetic, and medically accurate information about skin conditions. "
    "Always remind users to consult a qualified dermatologist for diagnosis and treatment. "
    "Keep responses concise and easy to understand."
)

_openai_client: Optional[OpenAI] = None


def _get_openai() -> OpenAI:
    global _openai_client
    if _openai_client is None:
        # Prefer Groq (free tier) — falls back to OpenAI if GROQ_API_KEY not set
        groq_key = os.environ.get("GROQ_API_KEY", "")
        openai_key = os.environ.get("OPENAI_API_KEY", "")
        if groq_key:
            _openai_client = OpenAI(
                api_key=groq_key,
                base_url="https://api.groq.com/openai/v1",
            )
        elif openai_key:
            _openai_client = OpenAI(api_key=openai_key)
        else:
            raise HTTPException(status_code=500, detail="No AI API key set (GROQ_API_KEY or OPENAI_API_KEY)")
    return _openai_client


@app.post("/chat")
async def chat(body: ChatRequest) -> dict[str, str]:
    if not body.message.strip():
        raise HTTPException(status_code=400, detail="message is required")

    _LANGUAGE_NAMES = {"ur": "Urdu", "hi": "Hindi", "en": "English"}
    system = _SYSTEM_PROMPT
    if body.disease_context.strip():
        system += f" The user has been diagnosed with: {body.disease_context}."
    if body.language != "en":
        lang_name = _LANGUAGE_NAMES.get(body.language, body.language)
        system += f" Always respond in {lang_name} language only."

    try:
        use_groq = bool(os.environ.get("GROQ_API_KEY"))
        model = "llama-3.1-8b-instant" if use_groq else "gpt-4o-mini"
        response = _get_openai().chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": body.message},
            ],
            max_tokens=400,
            temperature=0.7,
        )
        return {"reply": response.choices[0].message.content.strip()}
    except HTTPException:
        raise
    except Exception as exc:
        print(f"[chat error] {exc}")
        raise HTTPException(status_code=500, detail=str(exc))


# ---------------------------------------------------------------------------
# /translate  — Google Translate
# ---------------------------------------------------------------------------

class TranslateRequest(BaseModel):
    text: str
    target_language: str = "en"


@app.post("/translate")
async def translate(body: TranslateRequest) -> dict[str, str]:
    if not body.text.strip():
        raise HTTPException(status_code=400, detail="text is required")

    try:
        result = GoogleTranslator(source="auto", target=body.target_language).translate(body.text)
        return {"translated_text": result}
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


# ---------------------------------------------------------------------------
# /doctors  — Real Pakistani dermatologists
# (Kaggle: umarzafar/pakistani-doctors-profiles-dataset, city-level geocoded)
# ---------------------------------------------------------------------------

class DoctorsRequest(BaseModel):
    lat: float
    lng: float
    disease: str = "skin condition"


def _jitter(seed: str, scale: float = 0.015) -> tuple[float, float]:
    """Small deterministic per-doctor offset so markers sharing a city don't
    all stack on the exact same point on the map."""
    digest = hashlib.md5(seed.encode()).hexdigest()
    a = int(digest[:8], 16) / 0xFFFFFFFF - 0.5
    b = int(digest[8:16], 16) / 0xFFFFFFFF - 0.5
    return a * 2 * scale, b * 2 * scale


def _to_float(value: str, default: float = 0.0) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _clean(value: str) -> str:
    return html.unescape(value or "").strip()


def _load_dermatologists() -> list[dict[str, Any]]:
    try:
        with open(CITY_COORDS_PATH, encoding="utf-8") as f:
            city_coords: dict[str, list[float]] = json.load(f)
    except (OSError, json.JSONDecodeError):
        return []

    doctors = []
    try:
        with open(DOCTORS_CSV_PATH, encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                specialization = _clean(row.get("Specialization", ""))
                if "dermatolog" not in specialization.lower():
                    continue
                city = row.get("City", "").strip()
                coord = city_coords.get(city)
                if coord is None:
                    continue

                name = _clean(row.get("Doctor Name", ""))
                jlat, jlng = _jitter(f"{name}|{city}")
                satisfaction = min(_to_float(row.get("Patient Satisfaction Rate(%age)")), 100.0)

                doctors.append({
                    "name": name,
                    "specialization": specialization,
                    "qualification": _clean(row.get("Doctor Qualification", "")),
                    "experience_years": _to_float(row.get("Experience(Years)")),
                    "fee_pkr": _to_float(row.get("Fee(PKR)")),
                    "rating": round(satisfaction / 20, 1),
                    "address": _clean(row.get("Hospital Address", "")) or "Address not available",
                    "profile_url": _clean(row.get("Doctors Link", "")),
                    "lat": coord[0] + jlat,
                    "lng": coord[1] + jlng,
                })
    except OSError:
        return []

    return doctors


DERMATOLOGISTS = _load_dermatologists()


@app.post("/doctors")
async def find_doctors(body: DoctorsRequest) -> dict[str, Any]:
    origin = (body.lat, body.lng)
    ranked = [
        {**doc, "distance": round(geodesic(origin, (doc["lat"], doc["lng"])).km, 2)}
        for doc in DERMATOLOGISTS
    ]
    ranked.sort(key=lambda d: d["distance"])

    top = ranked[:20]
    for d in top:
        d["maps_url"] = f"https://www.google.com/maps/search/?api=1&query={d['lat']},{d['lng']}"

    return {"doctors": top, "disease": body.disease}


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False)

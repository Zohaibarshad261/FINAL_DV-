# DermaVision+ 🩺

AI-powered skin disease classification app. Take a photo of a skin condition, get an instant diagnosis with confidence score, symptoms, precautions, nearby doctors, and an AI chatbot — all in English, Urdu, or Hindi.

---

## Architecture

```
Flutter App (Android/iOS)
        │
        │  HTTP (multipart image upload / JSON)
        ▼
FastAPI Backend (Python)
        │
        ├── /predict  → EfficientNet-B0 PyTorch inference
        ├── /chat     → Groq AI chatbot (Llama 3.1)
        ├── /doctors  → OpenStreetMap Overpass API
        └── /translate→ Google Translate
        │
        └── Supabase  → Auth + image storage + reports DB
```

**Model:** EfficientNet-B0 trained on 22 skin disease classes  
**Backend:** FastAPI + PyTorch (runs on your PC or any server)  
**Frontend:** Flutter (Android + iOS)  
**Auth & Storage:** Supabase (free tier)

---

## Prerequisites

| Tool | Version | Download |
|------|---------|----------|
| Python | 3.10+ | [python.org](https://www.python.org/downloads/) |
| Flutter | 3.19+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Android Studio | Latest | For Android emulator / device |
| Git | Any | [git-scm.com](https://git-scm.com) |

---

## Project Structure

```
DermaVision+/
├── backend/
│   ├── main.py               ← FastAPI app (all routes)
│   ├── requirements.txt      ← Python dependencies
│   ├── .env.example          ← Environment variable template
│   └── best_efficientnet.pth ← Trained model (you supply this)
│
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config.dart       ← ⚠️ Change backend IP here
│   │   ├── screens/          ← All UI screens
│   │   ├── services/         ← API, auth, language logic
│   │   └── models/           ← Data models
│   ├── android/
│   │   └── app/src/main/AndroidManifest.xml
│   └── pubspec.yaml
│
├── skin_disease_classification_with_efficientnet.ipynb  ← Training notebook
├── classes.txt               ← All 22 class names
└── .gitignore
```

---

## Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/your-username/dermavision-plus.git
cd dermavision-plus
```

---

### 2. Get the trained model

The `.pth` file is not included in the repo (binary file). You have two options:

**Option A — Train it yourself (Google Colab recommended)**
- Open `skin_disease_classification_with_efficientnet.ipynb` in Google Colab
- Download the [Skin Disease Dataset](https://www.kaggle.com/datasets/pacificrm/skindiseasedataset) from Kaggle
- Run all cells — the model saves as `best_efficientnet.pth`
- Download it and place it inside `backend/`

**Option B — Get it from the original author**
- Contact the repo owner for the pre-trained weights

> The model uses **EfficientNet-B0** from `efficientnet_pytorch==0.7.1`  
> Input: 224×224 RGB, Normalize(mean=[0.485,0.485,0.485], std=[0.229,0.229,0.229])  
> Output: 22 classes (see `classes.txt`)

---

### 3. Set up the backend

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate it
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

#### Configure environment variables

```bash
# Copy the example file
cp .env.example .env
```

Open `backend/.env` and fill in your keys:

```env
GROQ_API_KEY=gsk_your_key_here        # Free at console.groq.com
OPENAI_API_KEY=sk-proj_optional       # Optional fallback
MODEL_PATH=best_efficientnet.pth      # Path to your .pth file
```

> **Getting a free Groq API key:**
> 1. Go to [console.groq.com](https://console.groq.com)
> 2. Sign up (free, no credit card needed)
> 3. Click **API Keys → Create API Key**
> 4. Copy the key starting with `gsk_...`

#### Start the backend

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

You should see:
```
[DermaVision+] Model loaded on cpu  ✓
INFO:     Uvicorn running on http://0.0.0.0:8000
```

Verify at `http://localhost:8000/health` — should return:
```json
{"status": "ok", "device": "cpu", "openai_key": "set"}
```

Interactive API docs at `http://localhost:8000/docs`

---

### 4. Set up Supabase

The app uses Supabase for user authentication, image storage, and scan history.

1. Create a free account at [supabase.com](https://supabase.com)
2. Create a new project
3. Go to **SQL Editor** and run:

```sql
-- Reports table
create table reports (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  disease_name text not null,
  confidence float not null,
  severity_level text,
  symptoms text,
  precautions text,
  image_url text,
  created_at timestamptz default now()
);

-- Enable Row Level Security
alter table reports enable row level security;

create policy "Users can manage their own reports"
  on reports for all
  using (auth.uid() = user_id);
```

4. Go to **Storage** → Create a new bucket named `skin-images` → set it to **Public**
5. Go to **Settings → API** and copy:
   - **Project URL** → `supabaseUrl`
   - **anon public key** → `supabaseAnonKey`

---

### 5. Configure Flutter

Open [flutter_app/lib/config.dart](flutter_app/lib/config.dart):

```dart
class AppConfig {
  // ⚠️  Replace with your PC's WiFi IP address
  // Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux) to find it
  // Your phone and PC must be on the same WiFi network
  static const String backendBaseUrl = 'http://YOUR_PC_IP:8000';

  // ⚠️  Replace with your Supabase credentials
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
}
```

> **Finding your PC's IP on Windows:**
> ```powershell
> ipconfig
> ```
> Look for **IPv4 Address** under your WiFi adapter (e.g. `192.168.1.5`)

> **Android emulator:** Use `http://10.0.2.2:8000` instead of a WiFi IP

---

### 6. Run the Flutter app

```bash
cd flutter_app
flutter pub get
flutter run
```

Make sure your phone is connected via USB with USB debugging enabled, or use an emulator.

---

## The 22 Skin Disease Classes

| # | Class | # | Class |
|---|-------|---|-------|
| 1 | Acne | 12 | Psoriasis |
| 2 | Actinic Keratosis | 13 | Rosacea |
| 3 | Benign Tumors | 14 | Seborrheic Keratoses |
| 4 | Bullous | 15 | Skin Cancer |
| 5 | Candidiasis | 16 | Sun/Sunlight Damage |
| 6 | Drug Eruption | 17 | Tinea |
| 7 | Eczema | 18 | Unknown/Normal |
| 8 | Infestations & Bites | 19 | Vascular Tumors |
| 9 | Lichen | 20 | Vasculitis |
| 10 | Lupus | 21 | Vitiligo |
| 11 | Moles | 22 | Warts |

---

## App Features

| Feature | Description |
|---------|-------------|
| **Skin Scan** | Pick from gallery or camera → get diagnosis with confidence % |
| **Result Screen** | Disease name, severity ring, symptoms & precautions as chips |
| **Top Predictions** | See top 5 possible conditions with confidence bars |
| **AI Chatbot** | Ask follow-up questions about your diagnosis (Groq/Llama 3.1) |
| **Nearby Doctors** | Map of dermatologists within 10 km using OpenStreetMap |
| **Scan History** | All past scans saved to your Supabase account |
| **Multi-language** | Switch between English, Urdu, and Hindi |
| **Auth** | Email/password login via Supabase |

---

## Changing the Language Model (Chatbot)

The chatbot defaults to **Groq (Llama 3.1 8B)** — free tier, 14,400 requests/day.

To switch models, edit [backend/main.py](backend/main.py):

```python
# Around line where model is selected:
model = "llama-3.1-8b-instant"   # current (Groq, free)
# model = "llama-3.3-70b-versatile"  # larger Groq model, more accurate
# model = "gpt-4o-mini"              # OpenAI (paid, set OPENAI_API_KEY)
```

---

## Changing the Number of Disease Classes

If you retrain with a different dataset:

1. Update `CLASS_NAMES` list in [backend/main.py](backend/main.py)
2. Update `DISEASE_INFO` dict with symptoms and precautions for each class
3. Update the `num_classes` value in `_load_model()`:
   ```python
   m = EfficientNet.from_name("efficientnet-b0", num_classes=YOUR_COUNT)
   ```
4. Retrain and replace `best_efficientnet.pth`

---

## Deployment (Optional)

### Deploy backend to Render (free tier)

1. Push your code to GitHub
2. Go to [render.com](https://render.com) → New → Web Service
3. Connect your GitHub repo, select the `backend/` folder
4. Settings:
   - **Build command:** `pip install -r requirements.txt`
   - **Start command:** `uvicorn main:app --host 0.0.0.0 --port $PORT`
5. Add environment variables (GROQ_API_KEY, MODEL_PATH, etc.) under **Environment**
6. Upload `best_efficientnet.pth` via Render's persistent disk
7. Once deployed, update `backendBaseUrl` in `config.dart` to your Render URL

---

## Common Issues

**`Model file not found`**
→ Make sure `best_efficientnet.pth` is inside the `backend/` folder

**`Cannot reach the server` on phone**
→ Check that phone and PC are on the same WiFi. Run `ipconfig`, update `config.dart` with the correct IP.

**`406 Not Acceptable` from Overpass API**
→ The backend automatically retries on 3 different Overpass servers. If all fail, the Overpass API may be temporarily down.

**`insufficient_quota` from OpenAI**
→ Your OpenAI account has no credits. Switch to Groq (free) by setting `GROQ_API_KEY` in `.env`.

**`override_params` error on backend startup**
→ Make sure `efficientnet_pytorch==0.7.1` is installed. Run `pip install efficientnet_pytorch==0.7.1`

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3.x (Dart) |
| Backend | FastAPI (Python) |
| ML Model | EfficientNet-B0 (PyTorch) |
| Auth & DB | Supabase (PostgreSQL) |
| Image Storage | Supabase Storage |
| AI Chatbot | Groq API (Llama 3.1) |
| Maps | OpenStreetMap + Overpass API |
| Translation | Google Translate (deep-translator) |

---

## License

MIT License — free to use, modify, and distribute.

---

> **Disclaimer:** This app is for educational purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified dermatologist.

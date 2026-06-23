# DermaVision+ — Setup Guide

## What you need

| Requirement | Status |
|---|---|
| Python 3.11+ | Install from python.org |
| Flutter 3.19+ | Install from flutter.dev |
| Supabase project | Already configured in `.env` |
| OpenAI API key | Already configured in `.env` |
| Google Maps API | ✅ Not needed — using OpenStreetMap |
| Google Translate API | ✅ Not needed — using deep-translator |

---

## Step 1 — Supabase Database Setup

Go to your Supabase dashboard → SQL Editor → run this:

```sql
-- profiles table
CREATE TABLE profiles (
  id uuid REFERENCES auth.users PRIMARY KEY,
  full_name text NOT NULL,
  email text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- reports table
CREATE TABLE reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  disease_name text NOT NULL,
  confidence float8 NOT NULL,
  symptoms text,
  precautions text,
  image_url text,
  created_at timestamptz DEFAULT now()
);

-- Enable Row-Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- RLS policies — users can only see their own data
CREATE POLICY "Users manage own profile" ON profiles
  FOR ALL USING (auth.uid() = id);

CREATE POLICY "Users manage own reports" ON reports
  FOR ALL USING (auth.uid() = user_id);
```

Then go to **Storage → Create bucket** named `skin-images` (set to **Public**).

---

## Step 2 — Get your Supabase Anon Key

1. Supabase Dashboard → **Settings → API**
2. Copy the **anon / public** key (NOT the service role key)
3. Open `flutter_app/lib/config.dart` and paste it:
   ```dart
   static const String supabaseAnonKey = 'paste-your-anon-key-here';
   ```

---

## Step 3 — Run the Flask Backend

```bash
cd backend

# Create and activate virtual environment
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # Mac/Linux

# Install all dependencies
pip install -r requirements.txt

# Start the server
python app.py
```

Flask will start at `http://localhost:5000`. The ONNX model loads automatically from the parent `Project/` folder.

> **Verify it works:** open `http://localhost:5000/health` in a browser — you should see `{"status": "ok", "model_loaded": true}`

---

## Step 4 — Run the Flutter App

```bash
cd flutter_app

# Install Flutter packages
flutter pub get

# Run on connected device or emulator
flutter run
```

> **Android emulator**: the default `backendBaseUrl` in `config.dart` is `http://10.0.2.2:5000` which correctly routes to your PC's localhost.
> **iOS simulator**: change it to `http://localhost:5000`.
> **Physical device**: use your PC's local IP, e.g. `http://192.168.1.x:5000`.

---

## Step 5 — Update labels.json (important!)

The file `backend/labels.json` currently maps 8 classes. You **must** update it to match your model's exact training class order:

```json
{
  "0": "Acne",
  "1": "Eczema",
  "2": "Melanoma",
  "3": "Psoriasis",
  "4": "Ringworm",
  "5": "Rosacea",
  "6": "Vitiligo",
  "7": "Warts"
}
```

Check your training notebook/script for the exact class names and their index order.

---

## Project Structure

```
Project/
├── TDD.md                        ← Technical Design Document
├── SETUP.md                      ← This file
├── updated_model.onnx            ← Model graph (auto-found by app.py)
├── updated_model.onnx.data       ← Model weights (must stay alongside .onnx)
│
├── backend/                      ← Flask API
│   ├── app.py                    ← Entry point
│   ├── routes/
│   │   ├── predict.py            ← POST /predict  (ONNX inference)
│   │   ├── doctors.py            ← POST /doctors  (Overpass/OSM)
│   │   ├── chat.py               ← POST /chat     (OpenAI GPT-3.5)
│   │   ├── translate.py          ← POST /translate (deep-translator)
│   │   └── reports.py            ← GET  /reports  (Supabase)
│   ├── utils/
│   │   ├── preprocess.py         ← Image pipeline matching training
│   │   └── supabase_client.py    ← Service-role Supabase singleton
│   ├── labels.json               ← Class index → disease name
│   ├── .env                      ← Supabase + OpenAI keys (filled in)
│   └── requirements.txt
│
└── flutter_app/                  ← Flutter frontend
    ├── pubspec.yaml
    └── lib/
        ├── main.dart             ← App entry, theme, routes
        ├── config.dart           ← URLs + Supabase anon key ← EDIT THIS
        ├── screens/              ← 10 screens
        ├── services/             ← api_service.dart, auth_service.dart
        ├── models/               ← Report, Doctor
        └── widgets/              ← Reusable UI components
```

---

## API Keys Summary

| Key | Where | Required |
|---|---|---|
| `SUPABASE_URL` | `backend/.env` | ✅ Filled in |
| `SUPABASE_SERVICE_ROLE_KEY` | `backend/.env` | ✅ Filled in |
| `OPENAI_API_KEY` | `backend/.env` | ✅ Filled in |
| Supabase anon key | `flutter_app/lib/config.dart` | ⚠️ **Needs filling** |
| Google Maps API key | — | ❌ Not needed |
| Google Translate API key | — | ❌ Not needed |

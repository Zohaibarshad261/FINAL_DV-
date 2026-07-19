/// DermaVision+ — App Configuration
/// Change backendBaseUrl to your deployed URL when going to production.
class AppConfig {
  // Switch between local dev and deployed backend
  static const String backendBaseUrl = 'https://batnat786-dermavision-backend.hf.space'; // Physical device → replace with your PC's WiFi IP
  // static const String backendBaseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // static const String backendBaseUrl = 'http://localhost:8000'; // iOS simulator
  // static const String backendBaseUrl = 'https://your-production-api.com'; // Production

  // Supabase — anon key only (never the service role key)
  // Get your anon key from: Supabase Dashboard → Settings → API → anon public
  static const String supabaseUrl = 'https://loxendedqnodfrkvmzya.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxveGVuZGVkcW5vZGZya3ZtenlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIxMTk4MzksImV4cCI6MjA5NzY5NTgzOX0.mUEPDz12QZxFZ-h1n-dvYWaPiT9Ia8xfwWcgyEHNHSU'; // TODO: paste your anon key

  // Map tiles use OpenStreetMap — no API key required
}
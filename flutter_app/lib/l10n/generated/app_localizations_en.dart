// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DermaVision+';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get ok => 'OK';

  @override
  String get splashTagline => 'Your skin health, AI-powered';

  @override
  String splashConditionsDetected(int count) {
    return '$count skin conditions detected';
  }

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get invalidEmailError => 'Enter a valid email';

  @override
  String get passwordTooShortError => 'Min 6 characters';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get networkError => 'Network error. Please try again.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinToday => 'Join DermaVision+ today';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameHint => 'John Doe';

  @override
  String get nameRequiredError => 'Name is required';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get accountCreatedMessage =>
      'Account created! Please sign in with your email and password.';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingFallbackName => 'there';

  @override
  String get aiDermatologyTagline => 'AI Dermatology';

  @override
  String get aiSkinCareBadge => 'AI Skin Care';

  @override
  String get tipSpf => 'Apply broad-spectrum SPF 30+ every day.';

  @override
  String get tipCheckSkin =>
      'Check your skin monthly for new or changing moles.';

  @override
  String get tipHydrate => 'Stay hydrated — skin reflects your water intake.';

  @override
  String get tipAvoidTanning =>
      'Avoid tanning beds; UV exposure accelerates aging.';

  @override
  String get tipSeeDermatologist =>
      'See a dermatologist annually for a full skin check.';

  @override
  String get statDiseases => 'Diseases';

  @override
  String get statPowered => 'Powered';

  @override
  String get statAvailable => 'Available';

  @override
  String get scanYourSkin => 'Scan Your Skin';

  @override
  String get uploadPhotoSubtitle => 'Upload a photo for instant AI analysis';

  @override
  String get recentDiagnoses => 'Recent Diagnoses';

  @override
  String get noDiagnosesYet => 'No diagnoses yet';

  @override
  String get tapScanToStart => 'Tap \"Scan Your Skin\" to get started';

  @override
  String get navHome => 'Home';

  @override
  String get navUpload => 'Upload';

  @override
  String get navReports => 'Reports';

  @override
  String get navProfile => 'Profile';

  @override
  String confidenceWithDate(String percent, String date) {
    return '$percent% confidence · $date';
  }

  @override
  String get conditionsWeDetect => 'Conditions We Detect';

  @override
  String get aiPoweredAnalysisSubtitle => 'AI-powered skin analysis';

  @override
  String skinConditionsCount(int count) {
    return '$count Skin Conditions';
  }

  @override
  String diseasesCountChip(int count) {
    return '$count Diseases';
  }

  @override
  String get tapToExploreDiseases => 'Tap to explore all diseases we detect';

  @override
  String get aiRangeDescription =>
      'Our AI can identify a wide range of skin conditions';

  @override
  String get scanSkinTitle => 'Scan Skin';

  @override
  String get tapToUploadImage => 'Tap to upload image';

  @override
  String get jpgPngSupported => 'JPG, PNG supported';

  @override
  String get cameraLabel => 'Camera';

  @override
  String get galleryLabel => 'Gallery';

  @override
  String get selectImageFirstError => 'Please select an image first.';

  @override
  String get mustBeLoggedInError => 'You must be logged in.';

  @override
  String get statusAnalyzing => 'Analyzing...';

  @override
  String get statusRunningAiAnalysis => 'Running AI analysis...';

  @override
  String get statusUploadingImage => 'Uploading image...';

  @override
  String get statusSavingReport => 'Saving report...';

  @override
  String get analyzeImage => 'Analyze Image';

  @override
  String get diagnosisResultTitle => 'Diagnosis Result';

  @override
  String get confidenceLabel => 'confidence';

  @override
  String get highSeverity => 'High Severity';

  @override
  String get mediumSeverity => 'Medium Severity';

  @override
  String get lowSeverity => 'Low Severity';

  @override
  String get symptomsLabel => 'Symptoms';

  @override
  String get precautionsLabel => 'Precautions';

  @override
  String get topPredictionsLabel => 'Top Predictions';

  @override
  String get rawLogitsLabel => 'Raw Logits (copy to compare with Python)';

  @override
  String get findNearbyDoctors => 'Find Nearby Doctors';

  @override
  String get askAiChatbot => 'Ask AI Chatbot';

  @override
  String get nearbyDoctorsTitle => 'Nearby Doctors';

  @override
  String get locationPermissionDeniedError =>
      'Location permission permanently denied. Enable it in app settings.';

  @override
  String get couldNotOpenMapsError => 'Could not open maps app';

  @override
  String get findingDoctorsNearYou => 'Finding doctors near you...';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String doctorsFoundNearby(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doctors found nearby',
      one: '1 doctor found nearby',
      zero: 'No doctors found nearby',
    );
    return '$_temp0';
  }

  @override
  String get pakistanDoctorsDirectory => 'Pakistan Doctors Directory';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get noDoctorsFoundTitle => 'No doctors found in this area';

  @override
  String get noDoctorsFoundMessage =>
      'Could not load the doctors directory.\nCheck your connection and try again.';

  @override
  String get searchAgain => 'Search Again';

  @override
  String yearsExpLabel(String years) {
    return '$years yrs exp';
  }

  @override
  String feeLabel(String amount) {
    return 'Rs $amount';
  }

  @override
  String get aiDermatologyAssistantTitle => 'AI Dermatology Assistant';

  @override
  String chatGreeting(String disease) {
    return 'Hello! I\'m your DermaVision+ assistant. You have been diagnosed with **$disease**. Feel free to ask me any questions about your condition, symptoms, or treatment options.';
  }

  @override
  String get chatErrorMessage =>
      'Sorry, I couldn\'t process your request. Please try again.';

  @override
  String get askAboutConditionHint => 'Ask about your condition...';

  @override
  String get myReportsTitle => 'My Reports';

  @override
  String get notLoggedInError => 'Not logged in.';

  @override
  String get noReportsYet => 'No reports yet';

  @override
  String get diagnosesWillAppearHere => 'Your diagnoses will appear here.';

  @override
  String get scanNow => 'Scan Now';

  @override
  String get overviewLabel => 'Overview';

  @override
  String get conditionOverview => 'Condition overview';

  @override
  String get noDetailInfoAvailable =>
      'Detailed information about this condition is not available yet.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get languageLabel => 'Language';

  @override
  String get appLanguageLabel => 'App Language';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirmMessage => 'Are you sure you want to sign out?';

  @override
  String languageSetMessage(String language) {
    return 'Language set to $language';
  }

  @override
  String get defaultUserName => 'User';
}

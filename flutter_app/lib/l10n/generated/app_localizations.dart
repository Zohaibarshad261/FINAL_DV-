import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DermaVision+'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your skin health, AI-powered'**
  String get splashTagline;

  /// No description provided for @splashConditionsDetected.
  ///
  /// In en, this message translates to:
  /// **'{count} skin conditions detected'**
  String splashConditionsDetected(int count);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmailError;

  /// No description provided for @passwordTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get passwordTooShortError;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again.'**
  String get networkError;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinToday.
  ///
  /// In en, this message translates to:
  /// **'Join DermaVision+ today'**
  String get joinToday;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get fullNameHint;

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequiredError;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @accountCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Account created! Please sign in with your email and password.'**
  String get accountCreatedMessage;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @greetingFallbackName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get greetingFallbackName;

  /// No description provided for @aiDermatologyTagline.
  ///
  /// In en, this message translates to:
  /// **'AI Dermatology'**
  String get aiDermatologyTagline;

  /// No description provided for @aiSkinCareBadge.
  ///
  /// In en, this message translates to:
  /// **'AI Skin Care'**
  String get aiSkinCareBadge;

  /// No description provided for @tipSpf.
  ///
  /// In en, this message translates to:
  /// **'Apply broad-spectrum SPF 30+ every day.'**
  String get tipSpf;

  /// No description provided for @tipCheckSkin.
  ///
  /// In en, this message translates to:
  /// **'Check your skin monthly for new or changing moles.'**
  String get tipCheckSkin;

  /// No description provided for @tipHydrate.
  ///
  /// In en, this message translates to:
  /// **'Stay hydrated — skin reflects your water intake.'**
  String get tipHydrate;

  /// No description provided for @tipAvoidTanning.
  ///
  /// In en, this message translates to:
  /// **'Avoid tanning beds; UV exposure accelerates aging.'**
  String get tipAvoidTanning;

  /// No description provided for @tipSeeDermatologist.
  ///
  /// In en, this message translates to:
  /// **'See a dermatologist annually for a full skin check.'**
  String get tipSeeDermatologist;

  /// No description provided for @statDiseases.
  ///
  /// In en, this message translates to:
  /// **'Diseases'**
  String get statDiseases;

  /// No description provided for @statPowered.
  ///
  /// In en, this message translates to:
  /// **'Powered'**
  String get statPowered;

  /// No description provided for @statAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statAvailable;

  /// No description provided for @scanYourSkin.
  ///
  /// In en, this message translates to:
  /// **'Scan Your Skin'**
  String get scanYourSkin;

  /// No description provided for @uploadPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo for instant AI analysis'**
  String get uploadPhotoSubtitle;

  /// No description provided for @recentDiagnoses.
  ///
  /// In en, this message translates to:
  /// **'Recent Diagnoses'**
  String get recentDiagnoses;

  /// No description provided for @noDiagnosesYet.
  ///
  /// In en, this message translates to:
  /// **'No diagnoses yet'**
  String get noDiagnosesYet;

  /// No description provided for @tapScanToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Scan Your Skin\" to get started'**
  String get tapScanToStart;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get navUpload;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @confidenceWithDate.
  ///
  /// In en, this message translates to:
  /// **'{percent}% confidence · {date}'**
  String confidenceWithDate(String percent, String date);

  /// No description provided for @conditionsWeDetect.
  ///
  /// In en, this message translates to:
  /// **'Conditions We Detect'**
  String get conditionsWeDetect;

  /// No description provided for @aiPoweredAnalysisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-powered skin analysis'**
  String get aiPoweredAnalysisSubtitle;

  /// No description provided for @skinConditionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Skin Conditions'**
  String skinConditionsCount(int count);

  /// No description provided for @diseasesCountChip.
  ///
  /// In en, this message translates to:
  /// **'{count} Diseases'**
  String diseasesCountChip(int count);

  /// No description provided for @tapToExploreDiseases.
  ///
  /// In en, this message translates to:
  /// **'Tap to explore all diseases we detect'**
  String get tapToExploreDiseases;

  /// No description provided for @aiRangeDescription.
  ///
  /// In en, this message translates to:
  /// **'Our AI can identify a wide range of skin conditions'**
  String get aiRangeDescription;

  /// No description provided for @scanSkinTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Skin'**
  String get scanSkinTitle;

  /// No description provided for @tapToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload image'**
  String get tapToUploadImage;

  /// No description provided for @jpgPngSupported.
  ///
  /// In en, this message translates to:
  /// **'JPG, PNG supported'**
  String get jpgPngSupported;

  /// No description provided for @cameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraLabel;

  /// No description provided for @galleryLabel.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryLabel;

  /// No description provided for @selectImageFirstError.
  ///
  /// In en, this message translates to:
  /// **'Please select an image first.'**
  String get selectImageFirstError;

  /// No description provided for @mustBeLoggedInError.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in.'**
  String get mustBeLoggedInError;

  /// No description provided for @statusAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get statusAnalyzing;

  /// No description provided for @statusRunningAiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Running AI analysis...'**
  String get statusRunningAiAnalysis;

  /// No description provided for @statusUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading image...'**
  String get statusUploadingImage;

  /// No description provided for @statusSavingReport.
  ///
  /// In en, this message translates to:
  /// **'Saving report...'**
  String get statusSavingReport;

  /// No description provided for @analyzeImage.
  ///
  /// In en, this message translates to:
  /// **'Analyze Image'**
  String get analyzeImage;

  /// No description provided for @diagnosisResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Result'**
  String get diagnosisResultTitle;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'confidence'**
  String get confidenceLabel;

  /// No description provided for @highSeverity.
  ///
  /// In en, this message translates to:
  /// **'High Severity'**
  String get highSeverity;

  /// No description provided for @mediumSeverity.
  ///
  /// In en, this message translates to:
  /// **'Medium Severity'**
  String get mediumSeverity;

  /// No description provided for @lowSeverity.
  ///
  /// In en, this message translates to:
  /// **'Low Severity'**
  String get lowSeverity;

  /// No description provided for @symptomsLabel.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptomsLabel;

  /// No description provided for @precautionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Precautions'**
  String get precautionsLabel;

  /// No description provided for @topPredictionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Top Predictions'**
  String get topPredictionsLabel;

  /// No description provided for @rawLogitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Raw Logits (copy to compare with Python)'**
  String get rawLogitsLabel;

  /// No description provided for @findNearbyDoctors.
  ///
  /// In en, this message translates to:
  /// **'Find Nearby Doctors'**
  String get findNearbyDoctors;

  /// No description provided for @askAiChatbot.
  ///
  /// In en, this message translates to:
  /// **'Ask AI Chatbot'**
  String get askAiChatbot;

  /// No description provided for @nearbyDoctorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby Doctors'**
  String get nearbyDoctorsTitle;

  /// No description provided for @locationPermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied. Enable it in app settings.'**
  String get locationPermissionDeniedError;

  /// No description provided for @couldNotOpenMapsError.
  ///
  /// In en, this message translates to:
  /// **'Could not open maps app'**
  String get couldNotOpenMapsError;

  /// No description provided for @findingDoctorsNearYou.
  ///
  /// In en, this message translates to:
  /// **'Finding doctors near you...'**
  String get findingDoctorsNearYou;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @doctorsFoundNearby.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No doctors found nearby} =1{1 doctor found nearby} other{{count} doctors found nearby}}'**
  String doctorsFoundNearby(int count);

  /// No description provided for @pakistanDoctorsDirectory.
  ///
  /// In en, this message translates to:
  /// **'Pakistan Doctors Directory'**
  String get pakistanDoctorsDirectory;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @noDoctorsFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No doctors found in this area'**
  String get noDoctorsFoundTitle;

  /// No description provided for @noDoctorsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not load the doctors directory.\nCheck your connection and try again.'**
  String get noDoctorsFoundMessage;

  /// No description provided for @searchAgain.
  ///
  /// In en, this message translates to:
  /// **'Search Again'**
  String get searchAgain;

  /// No description provided for @yearsExpLabel.
  ///
  /// In en, this message translates to:
  /// **'{years} yrs exp'**
  String yearsExpLabel(String years);

  /// No description provided for @feeLabel.
  ///
  /// In en, this message translates to:
  /// **'Rs {amount}'**
  String feeLabel(String amount);

  /// No description provided for @aiDermatologyAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Dermatology Assistant'**
  String get aiDermatologyAssistantTitle;

  /// No description provided for @chatGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m your DermaVision+ assistant. You have been diagnosed with **{disease}**. Feel free to ask me any questions about your condition, symptoms, or treatment options.'**
  String chatGreeting(String disease);

  /// No description provided for @chatErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I couldn\'t process your request. Please try again.'**
  String get chatErrorMessage;

  /// No description provided for @askAboutConditionHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about your condition...'**
  String get askAboutConditionHint;

  /// No description provided for @myReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReportsTitle;

  /// No description provided for @notLoggedInError.
  ///
  /// In en, this message translates to:
  /// **'Not logged in.'**
  String get notLoggedInError;

  /// No description provided for @noReportsYet.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReportsYet;

  /// No description provided for @diagnosesWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your diagnoses will appear here.'**
  String get diagnosesWillAppearHere;

  /// No description provided for @scanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get scanNow;

  /// No description provided for @overviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewLabel;

  /// No description provided for @conditionOverview.
  ///
  /// In en, this message translates to:
  /// **'Condition overview'**
  String get conditionOverview;

  /// No description provided for @noDetailInfoAvailable.
  ///
  /// In en, this message translates to:
  /// **'Detailed information about this condition is not available yet.'**
  String get noDetailInfoAvailable;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @appLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguageLabel;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmMessage;

  /// No description provided for @languageSetMessage.
  ///
  /// In en, this message translates to:
  /// **'Language set to {language}'**
  String languageSetMessage(String language);

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

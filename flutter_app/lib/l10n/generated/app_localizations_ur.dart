// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'ڈرماوژن+';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get tryAgain => 'دوبارہ کوشش کریں';

  @override
  String get ok => 'ٹھیک ہے';

  @override
  String get splashTagline => 'آپ کی جلد کی صحت، AI کے ساتھ';

  @override
  String splashConditionsDetected(int count) {
    return '$count جلد کی بیماریاں شناخت شدہ';
  }

  @override
  String get welcomeBack => 'خوش آمدید';

  @override
  String get signInToContinue => 'جاری رکھنے کے لیے سائن اِن کریں';

  @override
  String get emailLabel => 'ای میل';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'پاسورڈ';

  @override
  String get invalidEmailError => 'درست ای میل درج کریں';

  @override
  String get passwordTooShortError => 'کم از کم 6 حروف';

  @override
  String get signIn => 'سائن اِن';

  @override
  String get dontHaveAccount => 'اکاؤنٹ نہیں ہے؟ ';

  @override
  String get signUp => 'سائن اپ';

  @override
  String get networkError => 'نیٹ ورک میں خرابی۔ دوبارہ کوشش کریں۔';

  @override
  String get createAccount => 'اکاؤنٹ بنائیں';

  @override
  String get joinToday => 'آج ہی ڈرماوژن+ میں شامل ہوں';

  @override
  String get fullNameLabel => 'پورا نام';

  @override
  String get fullNameHint => 'جان ڈو';

  @override
  String get nameRequiredError => 'نام درکار ہے';

  @override
  String get alreadyHaveAccount => 'پہلے سے اکاؤنٹ ہے؟ ';

  @override
  String get accountCreatedMessage =>
      'اکاؤنٹ بن گیا! براہ کرم اپنی ای میل اور پاسورڈ سے سائن اِن کریں۔';

  @override
  String get greetingMorning => 'صبح بخیر';

  @override
  String get greetingAfternoon => 'دوپہر بخیر';

  @override
  String get greetingEvening => 'شام بخیر';

  @override
  String get greetingFallbackName => 'دوست';

  @override
  String get aiDermatologyTagline => 'AI ماہرِ جلد';

  @override
  String get aiSkinCareBadge => 'AI جلد کی دیکھ بھال';

  @override
  String get tipSpf => 'روزانہ SPF 30+ سن اسکرین لگائیں۔';

  @override
  String get tipCheckSkin =>
      'نئے یا بدلتے تِلوں کے لیے ہر ماہ اپنی جلد چیک کریں۔';

  @override
  String get tipHydrate =>
      'پانی کافی مقدار میں پئیں — جلد آپ کے پانی کی مقدار کی عکاسی کرتی ہے۔';

  @override
  String get tipAvoidTanning =>
      'ٹیننگ بیڈز سے پرہیز کریں؛ UV شعاعیں عمر رسیدگی کو تیز کرتی ہیں۔';

  @override
  String get tipSeeDermatologist =>
      'مکمل جلدی معائنے کے لیے سالانہ ماہرِ جلد سے ملیں۔';

  @override
  String get statDiseases => 'بیماریاں';

  @override
  String get statPowered => 'طاقت یافتہ';

  @override
  String get statAvailable => 'دستیاب';

  @override
  String get scanYourSkin => 'اپنی جلد اسکین کریں';

  @override
  String get uploadPhotoSubtitle => 'فوری AI تجزیے کے لیے تصویر اپ لوڈ کریں';

  @override
  String get recentDiagnoses => 'حالیہ تشخیصیں';

  @override
  String get noDiagnosesYet => 'ابھی تک کوئی تشخیص نہیں';

  @override
  String get tapScanToStart =>
      'شروع کرنے کے لیے \"اپنی جلد اسکین کریں\" پر ٹیپ کریں';

  @override
  String get navHome => 'ہوم';

  @override
  String get navUpload => 'اپ لوڈ';

  @override
  String get navReports => 'رپورٹس';

  @override
  String get navProfile => 'پروفائل';

  @override
  String confidenceWithDate(String percent, String date) {
    return '$percent% اعتماد · $date';
  }

  @override
  String get conditionsWeDetect => 'بیماریاں جو ہم شناخت کرتے ہیں';

  @override
  String get aiPoweredAnalysisSubtitle => 'AI سے چلنے والا جلد کا تجزیہ';

  @override
  String skinConditionsCount(int count) {
    return '$count جلد کی بیماریاں';
  }

  @override
  String diseasesCountChip(int count) {
    return '$count بیماریاں';
  }

  @override
  String get tapToExploreDiseases => 'تمام بیماریاں دیکھنے کے لیے ٹیپ کریں';

  @override
  String get aiRangeDescription =>
      'ہمارا AI جلد کی بیماریوں کی وسیع رینج شناخت کر سکتا ہے';

  @override
  String get scanSkinTitle => 'جلد اسکین کریں';

  @override
  String get tapToUploadImage => 'تصویر اپ لوڈ کرنے کے لیے ٹیپ کریں';

  @override
  String get jpgPngSupported => 'JPG، PNG قابلِ قبول';

  @override
  String get cameraLabel => 'کیمرہ';

  @override
  String get galleryLabel => 'گیلری';

  @override
  String get selectImageFirstError => 'پہلے ایک تصویر منتخب کریں۔';

  @override
  String get mustBeLoggedInError => 'آپ کا لاگ اِن ہونا ضروری ہے۔';

  @override
  String get statusAnalyzing => 'تجزیہ ہو رہا ہے...';

  @override
  String get statusRunningAiAnalysis => 'AI تجزیہ جاری ہے...';

  @override
  String get statusUploadingImage => 'تصویر اپ لوڈ ہو رہی ہے...';

  @override
  String get statusSavingReport => 'رپورٹ محفوظ ہو رہی ہے...';

  @override
  String get analyzeImage => 'تصویر کا تجزیہ کریں';

  @override
  String get diagnosisResultTitle => 'تشخیصی نتیجہ';

  @override
  String get confidenceLabel => 'اعتماد';

  @override
  String get highSeverity => 'زیادہ شدت';

  @override
  String get mediumSeverity => 'درمیانی شدت';

  @override
  String get lowSeverity => 'کم شدت';

  @override
  String get symptomsLabel => 'علامات';

  @override
  String get precautionsLabel => 'احتیاطی تدابیر';

  @override
  String get topPredictionsLabel => 'اہم پیشگوئیاں';

  @override
  String get rawLogitsLabel => 'خام لوجٹس (Python سے موازنے کے لیے کاپی کریں)';

  @override
  String get findNearbyDoctors => 'قریبی ڈاکٹرز تلاش کریں';

  @override
  String get askAiChatbot => 'AI چیٹ بوٹ سے پوچھیں';

  @override
  String get nearbyDoctorsTitle => 'قریبی ڈاکٹرز';

  @override
  String get locationPermissionDeniedError =>
      'مقام کی اجازت مستقل طور پر مسترد ہے۔ اسے ایپ کی سیٹنگز میں فعال کریں۔';

  @override
  String get couldNotOpenMapsError => 'میپس ایپ نہیں کھل سکی';

  @override
  String get findingDoctorsNearYou =>
      'آپ کے قریب ڈاکٹرز تلاش کیے جا رہے ہیں...';

  @override
  String get locationUnavailable => 'مقام دستیاب نہیں';

  @override
  String doctorsFoundNearby(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ڈاکٹرز قریب ملے',
      one: '1 ڈاکٹر قریب ملا',
      zero: 'قریب کوئی ڈاکٹر نہیں ملا',
    );
    return '$_temp0';
  }

  @override
  String get pakistanDoctorsDirectory => 'پاکستان ڈاکٹرز ڈائریکٹری';

  @override
  String get viewProfile => 'پروفائل دیکھیں';

  @override
  String get noDoctorsFoundTitle => 'اس علاقے میں کوئی ڈاکٹر نہیں ملا';

  @override
  String get noDoctorsFoundMessage =>
      'ڈاکٹرز کی ڈائریکٹری لوڈ نہیں ہو سکی۔\nاپنا کنکشن چیک کریں اور دوبارہ کوشش کریں۔';

  @override
  String get searchAgain => 'دوبارہ تلاش کریں';

  @override
  String yearsExpLabel(String years) {
    return '$years سال تجربہ';
  }

  @override
  String feeLabel(String amount) {
    return 'روپے $amount';
  }

  @override
  String get aiDermatologyAssistantTitle => 'AI ماہرِ جلد اسسٹنٹ';

  @override
  String chatGreeting(String disease) {
    return 'السلام علیکم! میں آپ کا ڈرماوژن+ اسسٹنٹ ہوں۔ آپ کو **$disease** کی تشخیص ہوئی ہے۔ اپنی حالت، علامات یا علاج کے بارے میں کوئی بھی سوال بلا جھجک پوچھیں۔';
  }

  @override
  String get chatErrorMessage =>
      'معذرت، آپ کی درخواست پر عمل نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get askAboutConditionHint => 'اپنی حالت کے بارے میں پوچھیں...';

  @override
  String get myReportsTitle => 'میری رپورٹس';

  @override
  String get notLoggedInError => 'لاگ اِن نہیں ہیں۔';

  @override
  String get noReportsYet => 'ابھی تک کوئی رپورٹ نہیں';

  @override
  String get diagnosesWillAppearHere => 'آپ کی تشخیصیں یہاں ظاہر ہوں گی۔';

  @override
  String get scanNow => 'ابھی اسکین کریں';

  @override
  String get overviewLabel => 'خلاصہ';

  @override
  String get conditionOverview => 'بیماری کا خلاصہ';

  @override
  String get noDetailInfoAvailable =>
      'اس بیماری کے بارے میں تفصیلی معلومات ابھی دستیاب نہیں ہیں۔';

  @override
  String get profileTitle => 'پروفائل';

  @override
  String get languageLabel => 'زبان';

  @override
  String get appLanguageLabel => 'ایپ کی زبان';

  @override
  String get signOut => 'سائن آؤٹ';

  @override
  String get signOutConfirmMessage => 'کیا آپ واقعی سائن آؤٹ کرنا چاہتے ہیں؟';

  @override
  String languageSetMessage(String language) {
    return 'زبان $language پر مقرر کر دی گئی';
  }

  @override
  String get defaultUserName => 'صارف';
}

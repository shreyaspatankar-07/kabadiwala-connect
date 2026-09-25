import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In mr, this message translates to:
  /// **'कबाडीवाला कनेक्ट'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In mr, this message translates to:
  /// **'ई-कचरा योग्य भावात विका'**
  String get welcomeMessage;

  /// No description provided for @listenPrompt.
  ///
  /// In mr, this message translates to:
  /// **'ऐकण्यासाठी येथे दाबा'**
  String get listenPrompt;

  /// No description provided for @selectLanguage.
  ///
  /// In mr, this message translates to:
  /// **'भाषा निवडा'**
  String get selectLanguage;

  /// No description provided for @marathiLanguage.
  ///
  /// In mr, this message translates to:
  /// **'मराठी'**
  String get marathiLanguage;

  /// No description provided for @hindiLanguage.
  ///
  /// In mr, this message translates to:
  /// **'हिंदी'**
  String get hindiLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In mr, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @languagePromptAudio.
  ///
  /// In mr, this message translates to:
  /// **'कृपया आपली पसंतीची भाषा निवडा'**
  String get languagePromptAudio;

  /// No description provided for @pinSetupTitle.
  ///
  /// In mr, this message translates to:
  /// **'सुरक्षित पिन तयार करा'**
  String get pinSetupTitle;

  /// No description provided for @enterPinPrompt.
  ///
  /// In mr, this message translates to:
  /// **'४ अंकांचा गुप्त पिन टाका'**
  String get enterPinPrompt;

  /// No description provided for @confirmPinPrompt.
  ///
  /// In mr, this message translates to:
  /// **'तोच पिन पुन्हा टाका'**
  String get confirmPinPrompt;

  /// No description provided for @pinMismatchError.
  ///
  /// In mr, this message translates to:
  /// **'दोन्ही पिन जुळत नाहीत, पुन्हा प्रयत्न करा'**
  String get pinMismatchError;

  /// No description provided for @pinSavedSuccess.
  ///
  /// In mr, this message translates to:
  /// **'तुमचा पिन सुरक्षित जतन झाला आहे'**
  String get pinSavedSuccess;

  /// No description provided for @phoneOptional.
  ///
  /// In mr, this message translates to:
  /// **'मोबाईल नंबर (ऐच्छिक)'**
  String get phoneOptional;

  /// No description provided for @submitAction.
  ///
  /// In mr, this message translates to:
  /// **'पुढे जा'**
  String get submitAction;

  /// No description provided for @clearAction.
  ///
  /// In mr, this message translates to:
  /// **'खोडा'**
  String get clearAction;

  /// No description provided for @unlockPrompt.
  ///
  /// In mr, this message translates to:
  /// **'अ‍ॅप उघडण्यासाठी पिन टाका'**
  String get unlockPrompt;

  /// No description provided for @tabAddLot.
  ///
  /// In mr, this message translates to:
  /// **'माल जोडा'**
  String get tabAddLot;

  /// No description provided for @tabPriceBoard.
  ///
  /// In mr, this message translates to:
  /// **'दर फलक'**
  String get tabPriceBoard;

  /// No description provided for @tabEarnings.
  ///
  /// In mr, this message translates to:
  /// **'कमाई'**
  String get tabEarnings;

  /// No description provided for @tabSafety.
  ///
  /// In mr, this message translates to:
  /// **'सुरक्षा'**
  String get tabSafety;

  /// No description provided for @addLotTitle.
  ///
  /// In mr, this message translates to:
  /// **'नवीन ई-कचरा माल जोडा'**
  String get addLotTitle;

  /// No description provided for @takePhoto.
  ///
  /// In mr, this message translates to:
  /// **'फोटो काढा'**
  String get takePhoto;

  /// No description provided for @photoCaptured.
  ///
  /// In mr, this message translates to:
  /// **'फोटो घेतला'**
  String get photoCaptured;

  /// No description provided for @selectCategory.
  ///
  /// In mr, this message translates to:
  /// **'प्रकार निवडा'**
  String get selectCategory;

  /// No description provided for @weightKg.
  ///
  /// In mr, this message translates to:
  /// **'वजन (किलो)'**
  String get weightKg;

  /// No description provided for @estimatedPrice.
  ///
  /// In mr, this message translates to:
  /// **'अंदाजे सरकारी भाव'**
  String get estimatedPrice;

  /// No description provided for @saveOffline.
  ///
  /// In mr, this message translates to:
  /// **'माल सुरक्षित जतन करा'**
  String get saveOffline;

  /// No description provided for @lotSavedSuccess.
  ///
  /// In mr, this message translates to:
  /// **'माल यशस्वीरीत्या नोंदवला गेला'**
  String get lotSavedSuccess;

  /// No description provided for @catCrt.
  ///
  /// In mr, this message translates to:
  /// **'सीआरटी / जुना टीव्ही'**
  String get catCrt;

  /// No description provided for @catLcd.
  ///
  /// In mr, this message translates to:
  /// **'एलसीडी / एलईडी स्क्रीन'**
  String get catLcd;

  /// No description provided for @catPcb.
  ///
  /// In mr, this message translates to:
  /// **'सर्किट बोर्ड (पीसीबी)'**
  String get catPcb;

  /// No description provided for @catCables.
  ///
  /// In mr, this message translates to:
  /// **'तांब्याची वायर / केबल'**
  String get catCables;

  /// No description provided for @catBatteries.
  ///
  /// In mr, this message translates to:
  /// **'बॅटरी (लिथियम/लेड)'**
  String get catBatteries;

  /// No description provided for @catMotors.
  ///
  /// In mr, this message translates to:
  /// **'मोटर / कुलर पंप'**
  String get catMotors;

  /// No description provided for @catPlastics.
  ///
  /// In mr, this message translates to:
  /// **'इलेक्ट्रॉनिक प्लास्टिक'**
  String get catPlastics;

  /// No description provided for @priceBoardTitle.
  ///
  /// In mr, this message translates to:
  /// **'आजचे अधिकृत बाजार भाव'**
  String get priceBoardTitle;

  /// No description provided for @perKg.
  ///
  /// In mr, this message translates to:
  /// **'प्रति किलो'**
  String get perKg;

  /// No description provided for @verifiedRecycler.
  ///
  /// In mr, this message translates to:
  /// **'अधिकृत रिसायकलर'**
  String get verifiedRecycler;

  /// No description provided for @marketMinMax.
  ///
  /// In mr, this message translates to:
  /// **'किमान - कमाल दर'**
  String get marketMinMax;

  /// No description provided for @lastUpdated.
  ///
  /// In mr, this message translates to:
  /// **'ताजी अपडेट'**
  String get lastUpdated;

  /// No description provided for @earningsTitle.
  ///
  /// In mr, this message translates to:
  /// **'माझा हिशोब व कमाई'**
  String get earningsTitle;

  /// No description provided for @totalEarnings.
  ///
  /// In mr, this message translates to:
  /// **'एकूण मिळालेली रक्कम'**
  String get totalEarnings;

  /// No description provided for @pendingDues.
  ///
  /// In mr, this message translates to:
  /// **'येणे बाकी रक्कम'**
  String get pendingDues;

  /// No description provided for @cashReceived.
  ///
  /// In mr, this message translates to:
  /// **'रोख रक्कम मिळाली'**
  String get cashReceived;

  /// No description provided for @recentTransactions.
  ///
  /// In mr, this message translates to:
  /// **'मागील व्यवहार'**
  String get recentTransactions;

  /// No description provided for @rupeeSymbol.
  ///
  /// In mr, this message translates to:
  /// **'₹'**
  String get rupeeSymbol;

  /// No description provided for @safetyTitle.
  ///
  /// In mr, this message translates to:
  /// **'कामगारांची सुरक्षा व नियम'**
  String get safetyTitle;

  /// No description provided for @safetyWarningHigh.
  ///
  /// In mr, this message translates to:
  /// **'धोकादायक! हातमोजे आणि मास्क वापरा'**
  String get safetyWarningHigh;

  /// No description provided for @safetyRuleBatteries.
  ///
  /// In mr, this message translates to:
  /// **'बॅटरी कधीही कापू नका किंवा जाळू नका'**
  String get safetyRuleBatteries;

  /// No description provided for @safetyRuleCrt.
  ///
  /// In mr, this message translates to:
  /// **'सीआरटी ट्यूब फोडू नका, विषारी वायू असतो'**
  String get safetyRuleCrt;

  /// No description provided for @safetyRuleCables.
  ///
  /// In mr, this message translates to:
  /// **'वायर जाळू नका, प्लास्टिक वेगळे करा'**
  String get safetyRuleCables;

  /// No description provided for @listenSafetyAudio.
  ///
  /// In mr, this message translates to:
  /// **'सुरक्षा नियम ऐका'**
  String get listenSafetyAudio;

  /// No description provided for @statusOffline.
  ///
  /// In mr, this message translates to:
  /// **'ऑफलाइन - माहिती फोनमध्ये सुरक्षित'**
  String get statusOffline;

  /// No description provided for @statusOnline.
  ///
  /// In mr, this message translates to:
  /// **'ऑनलाइन - माहिती सरकारकडे नोंदवली'**
  String get statusOnline;

  /// No description provided for @syncPending.
  ///
  /// In mr, this message translates to:
  /// **'सिंक बाकी (डेटा सुरक्षित)'**
  String get syncPending;

  /// No description provided for @syncSuccess.
  ///
  /// In mr, this message translates to:
  /// **'सर्व डेटा सिंक झाला'**
  String get syncSuccess;

  /// No description provided for @syncNow.
  ///
  /// In mr, this message translates to:
  /// **'आता सिंक करा'**
  String get syncNow;
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
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

/// Audio asset mappings and vernacular spoken scripts for low-literacy users.
/// Keyed by string ID in each language (mr: Marathi, hi: Hindi, en: English).
/// Every interactive screen and message has a spoken audio entry.
library;

class AudioMap {
  AudioMap._();

  static const Map<String, Map<String, String>> spokenTranscripts = {
    'languagePrompt': {
      'mr': 'कृपया आपली पसंतीची भाषा निवडा. मराठीसाठी डावीकडे दाबा.',
      'hi': 'कृपया अपनी पसंदीदा भाषा चुनें। हिंदी के लिए बीच में दबाएं।',
      'en': 'Please select your preferred language.',
    },
    'enterPinPrompt': {
      'mr': 'आपला चार अंकी गुप्त पिन टाका. हा पिन कोणालाही सांगू नका.',
      'hi': 'अपना चार अंकों का गुप्त पिन दर्ज करें। यह पिन किसी को न बताएं।',
      'en': 'Enter your 4 digit secret PIN. Keep it confidential.',
    },
    'confirmPinPrompt': {
      'mr': 'खात्री करण्यासाठी तोच पिन पुन्हा एकदा टाका.',
      'hi': 'पुष्टि के लिए वही पिन दोबारा दर्ज करें।',
      'en': 'Re-enter the same PIN to confirm.',
    },
    'pinMismatch': {
      'mr': 'दोन्ही पिन जुळत नाहीत. कृपया पुन्हा प्रयत्न करा.',
      'hi': 'दोनों पिन मेल नहीं खा रहे हैं। कृपया पुनः प्रयास करें।',
      'en': 'PINs do not match. Please try again.',
    },
    'pinSuccess': {
      'mr': 'तुमचा पिन सुरक्षित झाला आहे. आता तुम्ही अ‍ॅप वापरू शकता.',
      'hi': 'आपका पिन सुरक्षित हो गया है। अब आप ऐप का उपयोग कर सकते हैं।',
      'en': 'Your PIN has been saved securely.',
    },
    'tabAddLot': {
      'mr': 'नवीन ई-कचरा माल जोडण्यासाठी येथे दाबा. फोटो काढून वजन टाका.',
      'hi': 'नया ई-कचरा माल जोड़ने के लिए यहाँ दबाएं। फोटो लें और वजन दर्ज करें।',
      'en': 'Add new e-waste lot. Capture photo and enter weight.',
    },
    'tabPriceBoard': {
      'mr': 'आजचे अधिकृत सरकारी बाजार भाव पाहण्यासाठी येथे दाबा.',
      'hi': 'आज के अधिकृत सरकारी बाजार भाव देखने के लिए यहाँ दबाएं।',
      'en': 'View today\'s authorized market rates and price board.',
    },
    'tabEarnings': {
      'mr': 'तुमची एकूण कमाई आणि शिल्लक रक्कम तपासण्यासाठी येथे दाबा.',
      'hi': 'अपनी कुल कमाई और बकाया राशि देखने के लिए यहाँ दबाएं।',
      'en': 'Check your total earnings and ledger balance.',
    },
    'tabSafety': {
      'mr': 'ई-कचरा सुरक्षितपणे हाताळण्याचे नियम आणि इशारे ऐका.',
      'hi': 'ई-कचरा सुरक्षित रूप से संभालने के नियम और सावधानियां सुनें।',
      'en': 'Listen to safety guidelines and hazardous material warnings.',
    },
    'offlineNotice': {
      'mr': 'इंटरनेट नाही. काळजी करू नका, सर्व माहिती फोनमध्ये सुरक्षित राहील.',
      'hi': 'इंटरनेट नहीं है। चिंता न करें, सारी जानकारी फोन में सुरक्षित रहेगी।',
      'en': 'No internet. All data is saved safely offline on device.',
    },
    'syncSuccess': {
      'mr': 'सर्व माहिती सरकारी सर्व्हरवर सुरक्षित जमा झाली आहे.',
      'hi': 'सारी जानकारी सरकारी सर्वर पर सुरक्षित जमा हो गई है।',
      'en': 'All pending transactions have synced with the server.',
    },
    'photoCaptured': {
      'mr': 'फोटो घेतला गेला. कॅमेरा मॉडेलने मालाचा प्रकार ओळखला आहे.',
      'hi': 'फोटो ले लिया गया। कैमरा मॉडल ने माल का प्रकार पहचान लिया है।',
      'en': 'Photo captured. AI model has suggested material categories.',
    },
    'selectCategory': {
      'mr': 'स्क्रीनवरील योग्य प्रकारावर दाबा, किंवा खालील इतर प्रकार निवडा.',
      'hi': 'स्क्रीन पर सही प्रकार पर दबाएं, या नीचे अन्य विकल्प चुनें।',
      'en': 'Tap the matching material category or pick from the list.',
    },
    'weightPrompt': {
      'mr': 'मोठ्या कीपॅडवर मालाचे वजन टाका. किलो किंवा ग्रॅम निवडा.',
      'hi': 'बड़े कीपैड पर माल का वजन दर्ज करें। किलो या ग्राम चुनें।',
      'en': 'Enter item weight on the keypad. Choose kg or grams.',
    },
    'lotSavedSuccess': {
      'mr': 'माल सुरक्षित जतन झाला. इंटरनेट आल्यावर आपोआप सिंक होईल.',
      'hi': 'माल सुरक्षित सहेज लिया गया। इंटरनेट आने पर अपने आप सिंक होगा।',
      'en': 'Lot saved offline. It will synchronize once internet is restored.',
    },
    'privacyNotice': {
      'mr': 'तुमची गोपनीयता सुरक्षित आहे. आम्ही आधार क्रमांक किंवा नाव कधीही गोळा करत नाही. फक्त ई-कचऱ्याचे वजन व भाव नोंदवले जातात.',
      'hi': 'आपकी गोपनीयता सुरक्षित है। हम आधार नंबर या नाम कभी नहीं मांगते। केवल वजन और भाव दर्ज होता है।',
      'en': 'Your privacy is protected. We never collect Aadhaar or real names. Only scrap weights and rates are stored.',
    },
    'dataDeletedNotice': {
      'mr': 'तुमचा सर्व डेटा यशस्वीरीत्या नष्ट करण्यात आला आहे.',
      'hi': 'आपका सारा डेटा सफलतापूर्वक हटा दिया गया है।',
      'en': 'All your personal data has been erased successfully.',
    },
  };

  /// Returns asset audio path keyed by string ID and locale code
  static String getAudioPath(String stringId, String locale) {
    return 'assets/audio/$locale/$stringId.mp3';
  }

  /// Returns spoken transcript text for audio read-aloud or speech fallback
  static String getSpokenText(String stringId, String locale) {
    final lang = spokenTranscripts[stringId];
    if (lang != null && lang.containsKey(locale)) {
      return lang[locale]!;
    }
    return lang?['mr'] ?? '';
  }

  /// Generate dynamic spoken value estimate text
  static String getEstimateSpokenText(int amount, String locale) {
    switch (locale) {
      case 'hi':
        return 'अनुमानित सरकारी भाव लगभग $amount रुपये है।';
      case 'en':
        return 'Estimated government rate is approximately $amount Rupees.';
      case 'mr':
      default:
        return 'अंदाजे सरकारी भाव सुमारे $amount रुपये आहे.';
    }
  }

  /// Generate dynamic spoken text for price board category, rate and trend
  static String getPriceDetailSpokenText({
    required String category,
    required int pricePerKg,
    required String trend,
    required String locale,
  }) {
    switch (locale) {
      case 'hi':
        final trendText = trend == 'up'
            ? 'भाव बढ़ गया है।'
            : trend == 'down'
                ? 'भाव गिर गया है।'
                : 'भाव स्थिर है।';
        return '$category: आज का सरकारी भाव $pricePerKg रुपये प्रति किलो है। $trendText';
      case 'en':
        final trendText = trend == 'up'
            ? 'Price is rising.'
            : trend == 'down'
                ? 'Price is falling.'
                : 'Price is stable.';
        return '$category: Rate is $pricePerKg rupees per kilogram. $trendText';
      case 'mr':
      default:
        final trendText = trend == 'up'
            ? 'भाव वाढला आहे.'
            : trend == 'down'
                ? 'भाव कमी झाला आहे.'
                : 'भाव स्थिर आहे.';
        return '$category: आजचा सरकारी भाव $pricePerKg रुपये प्रति किलो आहे. $trendText';
    }
  }

  static String getBestBuyerSpokenText({
    required String recyclerName,
    required double distanceKm,
    required double ratePerKg,
    required String locale,
  }) {
    final distStr = distanceKm.toStringAsFixed(distanceKm.truncateToDouble() == distanceKm ? 0 : 1);
    final rateStr = ratePerKg.toStringAsFixed(ratePerKg.truncateToDouble() == ratePerKg ? 0 : 1);
    switch (locale) {
      case 'hi':
        return '$recyclerName, $distStr किलोमीटर दूर, $rateStr रुपये प्रति किलो';
      case 'en':
        return '$recyclerName, $distStr km away, $rateStr rupees per kg';
      case 'mr':
      default:
        return '$recyclerName, $distStr किलोमीटर दूर, $rateStr रुपये प्रति किलो';
    }
  }
}

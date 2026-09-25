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
}

"""Safety Guidance Service managing multilingual safety cards, seeding, and collector acknowledgements."""

from datetime import UTC, datetime
from typing import Any
import uuid
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Session

from app.models.schema import HazardLevel, SafetyAcknowledgement, SafetyContent
from app.schemas.safety import (
    SafetyAcknowledgeRequest,
    SafetyAcknowledgeResponse,
    SafetyCardLocalized,
)

# -----------------------------------------------------------------------------
# Core 8 Safety Topics Data (Authoritative Multilingual Content)
# -----------------------------------------------------------------------------

SEED_SAFETY_CARDS: list[dict[str, Any]] = [
    {
        "id": "SAFE-CABLE-01",
        "topic_id": "cables_burn",
        "category": "cables",
        "hazard_level": HazardLevel.DANGER,
        "pictogram": "cable_flame_cross",
        "category_trigger": "cables",
        "condition_trigger": None,
        "title_vernacular": {
            "mr": "तांब्यासाठी केबल कधीही जाळू नका",
            "hi": "तांबा निकालने के लिए केबल कभी न जलाएं",
            "en": "Never burn cables for copper recovery",
        },
        "summary_vernacular": {
            "mr": "केबल जाळल्याने विषारी वायू तयार होतो आणि फुफ्फुसांचे नुकसान होते.",
            "hi": "केबल जलाने से जहरीला धुआं निकलता है और फेफड़े खराब होते हैं।",
            "en": "Burning wire insulation releases toxic dioxins that damage your lungs.",
        },
        "instructions_vernacular": {
            "mr": [
                "१. केबल जाळल्यास डायऑक्सिन आणि फ्युरॉन हे विषारी वायू हवेत पसरतात.",
                "२. तांब्याची तार काढण्यासाठी यांत्रिक वायर स्ट्रिपर किंवा कटर वापरा.",
                "३. प्लास्टिक कोटिंग सुरक्षितपणे गोळा करून पुनर्प्रक्रिया करणाऱ्याकडे पाठवा.",
                "४. काम करताना हातमोजे आणि मास्कचा वापर करा.",
            ],
            "hi": [
                "१. केबल जलाने से डाइऑक्सिन और फ्यूरान जैसी जहरीली गैसें निकलती हैं।",
                "२. तांबे का तार निकालने के लिए मैकेनिकल वायर स्ट्रिपर या कटर का इस्तेमाल करें।",
                "३. प्लास्टिक कोटिंग को सुरक्षित रूप से रीसाइक्लर को दें।",
                "४. काम करते समय हमेशा दस्ताने और मास्क पहनें।",
            ],
            "en": [
                "1. Burning insulation produces cancer-causing toxic fumes and black carbon.",
                "2. Use mechanical wire strippers or hand utility knives to peel insulation.",
                "3. Segregate clean stripped plastic insulation for formal plastic recyclers.",
                "4. Always wear puncture-resistant gloves and safety goggles.",
            ],
        },
        "dos": {
            "mr": [
                "यांत्रिक कटर किंवा वायर स्ट्रिपर वापरा",
                "प्लास्टिक आवरण वेगळे गोळा करा",
                "हवेशीर मोकळ्या जागेत काम करा",
            ],
            "hi": [
                "मैकेनिकल स्ट्रिपर या कटर का उपयोग करें",
                "प्लास्टिक को अलग सुरक्षित रखें",
                "हवादार खुली जगह पर काम करें",
            ],
            "en": [
                "Use mechanical wire strippers or manual peelers",
                "Store clean stripped copper separately",
                "Work in well-ventilated open areas",
            ],
        },
        "donts": {
            "mr": [
                "उघड्यावर किंवा भट्टीत केबल जाळू नका",
                "जळणारा धूर श्वासात घेऊ नका",
                "लहान मुलांना कामाच्या जागेजवळ थांबू देऊ नका",
            ],
            "hi": [
                "खुले में या भट्टी में केबल कभी न जलाएं",
                "धुएं को सांस में न लें",
                "बच्चों को कार्यक्षेत्र से दूर रखें",
            ],
            "en": [
                "Never burn cables in open pits or barrels",
                "Never inhale burning plastic fumes",
                "Do not allow children near sorting zones",
            ],
        },
        "audio_prompt_urls": {
            "mr": "audio/safety_cables_burn_mr.mp3",
            "hi": "audio/safety_cables_burn_hi.mp3",
            "en": "audio/safety_cables_burn_en.mp3",
        },
    },
    {
        "id": "SAFE-CRT-01",
        "topic_id": "crt_monitor",
        "category": "CRT",
        "hazard_level": HazardLevel.DANGER,
        "pictogram": "crt_hazard",
        "category_trigger": "CRT",
        "condition_trigger": None,
        "title_vernacular": {
            "mr": "CRT मॉनिटर किंवा टीव्ही कधीही फोडू नका",
            "hi": "CRT मॉनिटर या टीवी कभी न तोड़ें",
            "en": "Never break or drill CRT monitors/TVs",
        },
        "summary_vernacular": {
            "mr": "सीआरटी ट्यूबमध्ये व्हॅक्यूम आणि शिसे (Lead) असते, फुटल्यास मोठा स्फोट होऊ शकतो.",
            "hi": "CRT ट्यूब में वैक्यूम और सीसा (लेड) होता है, टूटने पर विस्फोट हो सकता है।",
            "en": "Vacuum implosion hazard with toxic lead and phosphor dust.",
        },
        "instructions_vernacular": {
            "mr": [
                "१. सीआरटी काचेच्या मागे व्हॅक्यूम असतो, छिद्र पाडल्यास ट्यूब फुटून काच उडते.",
                "२. आतील बाजूला विषारी फॉस्फर पावडर आणि जड शिसे (Lead) असते.",
                "३. संपूर्ण सीआरटी युनिट न फोडता अधिकृत रिसायकलरकडे द्या.",
                "४. वाहतूक करताना काळजीपूर्वक हाताळा.",
            ],
            "hi": [
                "१. सीआरटी के अंदर वैक्यूम होता है, छेद करने पर ट्यूब जोरदार धमाके के साथ फट सकती है।",
                "२. अंदर जहरीला फॉस्फर पाउडर और भारी लेड होता है।",
                "३. पूरे सीआरटी यूनिट को बिना तोड़े अधिकृत रीसाइक्लर को सौंपें।",
                "४. ले जाते समय झटके न लगने दें।",
            ],
            "en": [
                "1. High vacuum inside tube can cause sudden violent inward implosion.",
                "2. Phosphor coating contains toxic heavy metals, cadmium, and lead.",
                "3. Always handover the intact CRT tube to EPR authorized recyclers.",
                "4. Store upright with protective padding during transport.",
            ],
        },
        "dos": {
            "mr": [
                "संपूर्ण CRT युनिट अखंड ठेवा",
                "जाड हातमोजे आणि गॉगल वापरा",
                "अधिकृत संकलन केंद्रात जमा करा",
            ],
            "hi": [
                "पूरी CRT स्क्रीन को साबुत रखें",
                "मोटे दस्ताने और चश्मा पहनें",
                "अधिकृत कलेक्शन सेंटर में जमा करें",
            ],
            "en": [
                "Keep CRT tube completely intact and unbroken",
                "Wear heavy-duty cut-resistant gloves and eye protection",
                "Handover to authorized downstream recyclers",
            ],
        },
        "donts": {
            "mr": [
                "हातोडीने काच फोडू नका",
                "मागील इलेक्ट्रॉन गन तोडू नका",
                "मुलांना CRT जवळ खेळू देऊ नका",
            ],
            "hi": [
                "हथौड़े से शीशा कभी न तोड़ें",
                "पीछे की गन को न तोड़ें",
                "बच्चों को पास न आने दें",
            ],
            "en": [
                "Never strike with hammer or chisel",
                "Never break neck or electron gun",
                "Never dump broken glass in municipal waste",
            ],
        },
        "audio_prompt_urls": {
            "mr": "audio/safety_crt_implosion_mr.mp3",
            "hi": "audio/safety_crt_implosion_hi.mp3",
            "en": "audio/safety_crt_implosion_en.mp3",
        },
    },
    {
        "id": "SAFE-BATT-01",
        "topic_id": "battery_crush",
        "category": "batteries",
        "hazard_level": HazardLevel.DANGER,
        "pictogram": "battery_fire",
        "category_trigger": "batteries",
        "condition_trigger": None,
        "title_vernacular": {
            "mr": "लिथियम बॅटरी कधीही कापू किंवा चेपू नका",
            "hi": "लिथियम बैटरी को कभी न काटें या दबाएं",
            "en": "Never puncture, heat or crush Li-ion batteries",
        },
        "summary_vernacular": {
            "mr": "लिथियम बॅटरी दबल्यास किंवा गरम झाल्यास त्वरित आग लागते आणि स्फोट होतो.",
            "hi": "लिथियम बैटरी दबने या गर्म होने पर तुरंत आग पकड़ती है और फटती है।",
            "en": "Lithium-ion cells enter thermal runaway and explode when punctured or crushed.",
        },
        "instructions_vernacular": {
            "mr": [
                "१. बॅटरीचे टोक (टर्मिनल्स) एकमेकांना चिकटल्यास स्पार्क होऊन आग लागते.",
                "२. बॅटरीच्या दोन्ही टोकांवर इन्सुलेशन टेप लावा.",
                "३. बॅटरी थेट उन्हात किंवा उष्णतेजवळ ठेवू नका.",
                "४. बॅटरी कधीही हातोड्याने चेपू नका किंवा उघडू नका.",
            ],
            "hi": [
                "१. बैटरी के दोनों सिरे आपस में टकराने से स्पार्क होकर आग लग सकती है।",
                "२. दोनों सिरों पर इंसुलेशन टेप चिपकाएं।",
                "३. बैटरी को सीधी धूप या गर्मी में न रखें।",
                "४. बैटरी को हथौड़े से कभी न दबाएं या खोलें।",
            ],
            "en": [
                "1. Internal short circuits trigger explosive thermal runaway in seconds.",
                "2. Tape both electrical terminals with non-conductive electrical tape.",
                "3. Store in fire-resistant dry containers away from direct sunlight.",
                "4. Never attempt to crush, puncture, or open battery packs.",
            ],
        },
        "dos": {
            "mr": [
                "टर्मिनल्सवर इन्सुलेशन टेप लावा",
                "कोरड्या आणि थंड जागी ठेवा",
                "प्लॅस्टिकच्या स्वतंत्र डब्यात ठेवा",
            ],
            "hi": [
                "टर्मिनल्स पर इंसुलेशन टेप लगाएं",
                "सूखी और ठंडी जगह रखें",
                "अलग प्लास्टिक डिब्बे में रखें",
            ],
            "en": [
                "Tape battery terminal contacts with electrical tape",
                "Store in a cool dry isolated container",
                "Keep sand or dry fire extinguisher nearby",
            ],
        },
        "donts": {
            "mr": [
                "बॅटरीवर हातोडी मारू नका",
                "पाण्यात किंवा आगीत टाकू नका",
                "धातूच्या सुट्ट्या वस्तूंमध्ये मिसळू नका",
            ],
            "hi": [
                "हथौड़े से न मारें",
                "पानी या आग में न फेंकें",
                "धातु की खुली चीजों के साथ न मिलाएं",
            ],
            "en": [
                "Never puncture with metal tools or nails",
                "Never dispose in water, moisture, or fire",
                "Never carry loose with loose metal screws or coins",
            ],
        },
        "audio_prompt_urls": {
            "mr": "audio/safety_battery_crush_mr.mp3",
            "hi": "audio/safety_battery_crush_hi.mp3",
            "en": "audio/safety_battery_crush_en.mp3",
        },
    },
    {
        "id": "SAFE-PCB-01",
        "topic_id": "pcb_acid",
        "category": "PCB",
        "hazard_level": HazardLevel.DANGER,
        "pictogram": "acid_corrosion",
        "category_trigger": "PCB",
        "condition_trigger": None,
        "title_vernacular": {
            "mr": "सर्किट बोर्डवर ॲसिड वॉश करू नका",
            "hi": "सर्किट बोर्ड पर एसिड कभी न डालें",
            "en": "Do not acid-leach circuit boards (PCBs)",
        },
        "summary_vernacular": {
            "mr": "ॲसिडच्या प्रक्रियेमुळे विषारी सायनाइड वायू आणि त्वचेचे गंभीर नुकसान होते.",
            "hi": "एसिड लीचिंग से जहरीली गैसें निकलती हैं और त्वचा गंभीर रूप से जल सकती है।",
            "en": "Open acid leaching releases deadly cyanide/NOx gases and causes acid burns.",
        },
        "instructions_vernacular": {
            "mr": [
                "१. सोने किंवा तांबे काढण्यासाठी नायट्रिक ॲसिड वापरणे अत्यंत धोकादायक आहे.",
                "२. यामुळे निघणारा धूर फुफ्फुसांना कायमचे निकामी करतो.",
                "३. ॲसिड कचरा जमिनीत मिसळल्यास पिण्याचे पाणी विषारी होते.",
                "४. पीसीबी बोर्ड अखंड ठेवून अधिकृत रिसायकलरला द्या.",
            ],
            "hi": [
                "१. सोना या तांबा निकालने के लिए नाइट्रिक एसिड का उपयोग जानलेवा है।",
                "२. इसका धुआं फेफड़ों को स्थायी नुकसान पहुंचाता है।",
                "३. तेजाब का पानी जमीन में जाने से पीने का पानी जहरीला हो जाता है।",
                "४. पीसीबी बोर्ड को सही हालत में सीधे रीसाइक्लर को दें।",
            ],
            "en": [
                "1. Using nitric acid or aqua regia releases lethal nitrogen dioxide fumes.",
                "2. Heavy metal sludge contaminates municipal water tables permanently.",
                "3. Precious metals can only be safely extracted in closed smelting refineries.",
                "4. Sell unstripped intact PCBs directly to authorized recyclers.",
            ],
        },
        "dos": {
            "mr": [
                "पीसीबी कोरड्या बॉक्समध्ये साठवा",
                "जाड रबरी हातमोजे वापरा",
                "अधिकृत ईपीआर रिसायकलरला विका",
            ],
            "hi": [
                "पीसीबी को सूखे डिब्बे में रखें",
                "रबर के मोटे दस्ताने पहनें",
                "अधिकृत EPR रीसाइक्लर को बेचें",
            ],
            "en": [
                "Keep circuit boards clean, dry and intact",
                "Wear chemical-resistant gloves when sorting",
                "Sell high/mid/low grade PCBs directly to verified buyers",
            ],
        },
        "donts": {
            "mr": [
                "तेजाब किंवा ॲसिडने बोर्ड धुवू नका",
                "गॅसवर किंवा स्टोव्हवर पीसीबी तापवू नका",
                "ॲसिड सांडपाणी नालीत सोडू नका",
            ],
            "hi": [
                "तेजाब से बोर्ड को कभी न धोएं",
                "आग या चूल्हे पर बोर्ड न तपाएं",
                "तेजाब का गंदा पानी नाली में न बहाएं",
            ],
            "en": [
                "Never perform backyard open-basin chemical leaching",
                "Never heat PCBs on open cooking stoves or torches",
                "Never discharge acid baths into ground drains",
            ],
        },
        "audio_prompt_urls": {
            "mr": "audio/safety_pcb_acid_mr.mp3",
            "hi": "audio/safety_pcb_acid_hi.mp3",
            "en": "audio/safety_pcb_acid_en.mp3",
        },
    },
    {
        "id": "SAFE-STOR-01",
        "topic_id": "safe_storage",
        "category": "storage",
        "hazard_level": HazardLevel.WARNING,
        "pictogram": "warehouse_storage",
        "category_trigger": None,
        "condition_trigger": None,
        "title_vernacular": {
            "mr": "ई-कचऱ्याची सुरक्षित साठवणूक कशी करावी",
            "hi": "ई-कचरे का सुरक्षित भंडारण कैसे करें",
            "en": "Safe storage of collected e-waste",
        },
        "summary_vernacular": {
            "mr": "ई-कचरा नेहमी कोरड्या, हवेशीर आणि मुलांच्या हाताबाहेर असलेल्या ठिकाणी ठेवा.",
            "hi": "ई-कचरा हमेशा सूखी, हवादार और बच्चों की पहुंच से दूर जगह रखें।",
            "en": "Store items off the ground in a well-ventilated, secure, dry area.",
        },
        "instructions_vernacular": {
            "mr": [
                "१. पावसाचे पाणी किंवा ओलावा लागू नये म्हणून मालाखाली लाकडी फळी (पॅलेट) ठेवा.",
                "२. बॅटरी, ट्यूबलाईट आणि पीसीबी वेगवेगळ्या बॉक्समध्ये ठेवा.",
                "३. साठवणूक कक्षात पाण्याचा निचरा आणि हवेची सोय असावी.",
                "४. मुलांच्या आणि पाळीव प्राण्यांच्या संपर्कात येऊ देऊ नका.",
            ],
            "hi": [
                "१. बारिश का पानी या नमी से बचाने के लिए नीचे लकड़ी का तख्ता रखें।",
                "२. बैटरी, ट्यूबलाइट और पीसीबी को अलग-अलग डिब्बों में रखें।",
                "३. भंडारण वाले कमरे में हवा आने-जाने की पूरी व्यवस्था हो।",
                "४. बच्चों और पालतू जानवरों की पहुंच से दूर रखें।",
            ],
            "en": [
                "1. Keep e-waste raised on wooden pallets to prevent rain water pooling.",
                "2. Segregate batteries, fluorescent tubes, and circuit boards into labeled crates.",
                "3. Ensure good cross-ventilation to prevent hazardous gas buildup.",
                "4. Secure the storage area strictly away from children and pets.",
            ],
        },
        "dos": {
            "mr": [
                "जमिनीपासून ५ इंच वर माल ठेवा",
                "वर्गवारीनुसार वेगळे कप्पे करा",
                "अग्निशामक वाळू किंवा सिलिंडर जवळ ठेवा",
            ],
            "hi": [
                "जमीन से ५ इंच ऊपर माल रखें",
                "सामान को श्रेणी अनुसार अलग रखें",
                "आग बुझाने के लिए रेत या सिलेंडर पास रखें",
            ],
            "en": [
                "Elevate storage crates above floor level",
                "Sort materials into distinct dedicated bins",
                "Keep dry fire sand buckets or extinguishers accessible",
            ],
        },
        "donts": {
            "mr": [
                "उघड्यावर पावसात माल ठेवू नका",
                "खोलीत विडी किंवा सिगारेट ओढू नका",
                "अतिउंच ढीग रचू नका",
            ],
            "hi": [
                "खुले में बारिश में माल न रखें",
                "भंडारण कक्ष में बीड़ी-सिगरेट न पिएं",
                "बहुत ऊंचा ढेर न लगाएं",
            ],
            "en": [
                "Never store uncovered in open rain or monsoons",
                "Never smoke or light matches inside e-waste sheds",
                "Never stack heavy CRT monitors or batteries higher than eye level",
            ],
        },
        "audio_prompt_urls": {
            "mr": "audio/safety_storage_safe_mr.mp3",
            "hi": "audio/safety_storage_safe_hi.mp3",
            "en": "audio/safety_storage_safe_en.mp3",
        },
    },
    {
        "id": "SAFE-BATT-02",
        "topic_id": "battery_smoke",
        "category": "batteries",
        "hazard_level": HazardLevel.DANGER,
        "pictogram": "battery_smoke_danger",
        "category_trigger": "batteries",
        "condition_trigger": None,
        "title_vernacular": {
            "mr": "बॅटरी फुगल्यास किंवा धूर आल्यास काय करावे",
            "hi": "बैटरी फूलने या धुआं निकलने पर क्या करें",
            "en": "What to do if a battery swells or smokes",
        },
        "summary_vernacular": {
            "mr": "बॅटरीला स्पर्श करू नका, वाळू किंवा माती टाका आणि त्वरित लांब व्हा.",
            "hi": "बैटरी को न छुएं, रेत या मिट्टी डालें और तुरंत दूर हट जाएं।",
            "en": "Do not touch, immediately isolate with dry sand, and evacuate area.",
        },
        "instructions_vernacular": {
            "mr": [
                "१. फुगलेली बॅटरी कधीही उघड्या हाताने उचलू नका.",
                "२. बॅटरीवर त्वरित कोरडी वाळू किंवा माती टाका, पाणी अजिबात टाकू नका.",
                "३. बॅटरी त्वरित घराबाहेर मोकळ्या मैदानात ठेवा.",
                "४. त्वरित जवळच्या अधिकृत रिसायकलरला माहिती द्या.",
            ],
            "hi": [
                "१. फूली हुई बैटरी को कभी भी नंगे हाथों से न छुएं।",
                "२. तुरंत सूखी रेत या मिट्टी डालें, पानी बिल्कुल न डालें।",
                "३. बैटरी को तुरंत घर से बाहर खुले मैदान में रखें।",
                "४. पास के अधिकृत रीसाइक्लर को तत्काल सूचित करें।",
            ],
            "en": [
                "1. Never handle swollen, hissing, or warm lithium batteries with bare hands.",
                "2. Smother completely with dry sand or Class D fire extinguisher; NEVER use water.",
                "3. Move carefully using metal tongs to an outdoor metal bucket.",
                "4. Contact your authorized aggregator for emergency hazardous pickup.",
            ],
        },
        "dos": {
            "mr": [
                "कोरडी वाळू किंवा माती वापरा",
                "घराबाहेर मोकळ्या हवेत ठेवा",
                "लोखंडी चिमटा किंवा झाकण वापरा",
            ],
            "hi": [
                "सूखी रेत या मिट्टी का इस्तेमाल करें",
                "घर से बाहर खुली हवा में रखें",
                "लोहे के चिमटे से उठाएं",
            ],
            "en": [
                "Smother with dry sandbox sand",
                "Isolate outside in an open well-ventilated area",
                "Handle using long metal tools or tongs",
            ],
        },
        "donts": {
            "mr": [
                "पाणी टाकू नका (पाण्याने आग भडकते)",
                "उघड्या हाताने स्पर्श करू नका",
                "बंद खोलीत थांबू नका",
            ],
            "hi": [
                "पानी बिल्कुल न डालें (पानी से आग भड़कती है)",
                "नंगे हाथों से न छुएं",
                "बंद कमरे में न रुकें",
            ],
            "en": [
                "NEVER pour water on burning lithium (causes hydrogen explosion)",
                "Never touch smoking cells with bare skin",
                "Never inhale white chemical battery fumes",
            ],
        },
        "audio_prompt_urls": {
            "mr": "audio/safety_battery_smoke_mr.mp3",
            "hi": "audio/safety_battery_smoke_hi.mp3",
            "en": "audio/safety_battery_smoke_en.mp3",
        },
    },
    {
        "id": "SAFE-PPE-01",
        "topic_id": "ppe_gloves",
        "category": "handling",
        "hazard_level": HazardLevel.WARNING,
        "pictogram": "ppe_gloves_mask",
        "category_trigger": None,
        "condition_trigger": None,
        "title_vernacular": {
            "mr": "माल हाताळताना हातमोजे व मास्क वापरा",
            "hi": "सामान छांटते समय दस्ताने और मास्क पहनें",
            "en": "Safe handling: wear gloves and mask when sorting",
        },
        "summary_vernacular": {
            "mr": "काच, जड धातू आणि धुळीपासून संरक्षणासाठी पीपीई (PPE) आवश्यक आहे.",
            "hi": "कांच, भारी धातुओं और धूल से बचाव के लिए पीपीई जरूरी है।",
            "en": "Prevent cuts, heavy metal absorption, and toxic dust inhalation.",
        },
        "instructions_vernacular": {
            "mr": [
                "१. ई-कचरा वर्गवारी करताना जाड चामड्याचे किंवा रबरी हातमोजे घाला.",
                "२. फॉस्फर धूळ आणि बारीक कणांपासून बचावासाठी N95 मास्क वापरा.",
                "३. कामाच्या शेवटी हात साबणाने स्वच्छ धुवूनच जेवण करा.",
                "४. पायात मजबूत बूट (शूज) घाला.",
            ],
            "hi": [
                "१. कचरा छांटते समय मोटे चमड़े या रबर के दस्ताने जरूर पहनें।",
                "२. धूल और जहरीले कणों से बचने के लिए N95 मास्क लगाएं।",
                "३. काम खत्म होने के बाद हाथ साबुन से अच्छी तरह धोकर ही भोजन करें।",
                "४. पैरों में मजबूत जूते पहनें।",
            ],
            "en": [
                "1. Wear heavy-duty puncture-resistant work gloves during all sorting.",
                "2. Wear an N95 particle mask to prevent inhaling leaded and phosphor dust.",
                "3. Thoroughly wash hands with soap and water before drinking or eating.",
                "4. Always wear closed-toe thick-soled work boots.",
            ],
        },
        "dos": {
            "mr": [
                "जाड हातमोजे आणि मास्क वापरा",
                "कामाच्या शेवटी हात साबणाने धुवा",
                "मजबूत बूट घाला",
            ],
            "hi": [
                "मोटे दस्ताने और मास्क का उपयोग करें",
                "काम के बाद साबुन से हाथ धोएं",
                "मजबूत जूते पहनें",
            ],
            "en": [
                "Wear cut-resistant safety gloves",
                "Wash hands thoroughly with soap before eating",
                "Wear safety footwear around heavy scrap",
            ],
        },
        "donts": {
            "mr": [
                "उघड्या हातांनी धारदार भाग धरू नका",
                "काम करताना तोंडाला हात लावू नका",
                "चप्पल घालून जड माल उचलू नका",
            ],
            "hi": [
                "नंगे हाथों से नुकीली चीजें न पकड़ें",
                "काम के दौरान चेहरे को न छुएं",
                "चप्पल पहनकर भारी माल न उठाएं",
            ],
            "en": [
                "Never handle cracked circuit boards with bare hands",
                "Never rub eyes or smoke while sorting scrap",
                "Never wear open slippers or sandals in scrap yards",
            ],
        },
        "audio_prompt_urls": {
            "mr": "audio/safety_ppe_gloves_mr.mp3",
            "hi": "audio/safety_ppe_gloves_hi.mp3",
            "en": "audio/safety_ppe_gloves_en.mp3",
        },
    },
    {
        "id": "SAFE-AID-01",
        "topic_id": "first_aid",
        "category": "first_aid",
        "hazard_level": HazardLevel.INFO,
        "pictogram": "first_aid_cross",
        "category_trigger": None,
        "condition_trigger": None,
        "title_vernacular": {
            "mr": "रासायनिक आणि भौतिक इजा झाल्यास प्रथमोपचार",
            "hi": "केमिकल और चोट लगने पर प्राथमिक चिकित्सा",
            "en": "First aid basics for chemical and physical exposure",
        },
        "summary_vernacular": {
            "mr": "ॲसिड किंवा काच लागल्यास त्वरित १० मिनिटे पाण्याने धुवा आणि डॉक्टरांकडे जा.",
            "hi": "एसिड या कांच लगने पर तुरंत १० मिनट तक पानी से धोएं और डॉक्टर के पास जाएं।",
            "en": "Flush chemical contact with clean running water for 15 minutes and seek care.",
        },
        "instructions_vernacular": {
            "mr": [
                "१. ॲसिड त्वचेवर पडल्यास त्वरित भरपूर वाहत्या पाण्याने १५ मिनिटे धुवा.",
                "२. डोळ्यात धूळ किंवा रसायन गेल्यास डोळे चोळू नका, पाण्याने स्वच्छ करा.",
                "३. काचेमुळे जखम झाल्यास स्वच्छ कापडाने दाबून रक्तस्त्राव थांबवा.",
                "४. त्वरित जवळच्या प्राथमिक आरोग्य केंद्रात (PHC) जा.",
            ],
            "hi": [
                "१. एसिड त्वचा पर गिरने पर तुरंत १५ मिनट तक बहते पानी से धोएं।",
                "२. आंखों में केमिकल जाने पर आंखें न मलें, साफ पानी से धोएं।",
                "३. कांच से कटने पर साफ कपड़े से दबाकर खून रोकें।",
                "४. पास के सरकारी अस्पताल या डॉक्टर से तुरंत संपर्क करें।",
            ],
            "en": [
                "1. Flush chemical skin contact immediately under cold running water for 15 mins.",
                "2. If eyes are exposed, hold eyelids open and rinse thoroughly without rubbing.",
                "3. For deep cuts, apply firm pressure with a clean sterile cloth to stop bleeding.",
                "4. Seek immediate evaluation at the nearest Primary Health Centre (PHC).",
            ],
        },
        "dos": {
            "mr": [
                "भरपूर वाहत्या पाण्याने धुवा",
                "स्वच्छ कापडाने जखम बांधा",
                "तातडीने डॉक्टरांकडे जा",
            ],
            "hi": [
                "भरपूर बहते पानी से धोएं",
                "साफ कपड़े से घाव ढकें",
                "तुरंत डॉक्टर के पास जाएं",
            ],
            "en": [
                "Flush with clean flowing water continuously",
                "Apply direct pressure to bleeding cuts",
                "Keep local emergency and 108 ambulance numbers saved",
            ],
        },
        "donts": {
            "mr": [
                "जखमेवर तेल किंवा हळद लावू नका",
                "डोळे चोळू नका",
                "गंभीर जखमेकडे दुर्लक्ष करू नका",
            ],
            "hi": [
                "घाव पर तेल या चूना न लगाएं",
                "आंखों को कभी न मलें",
                "चोट को नजरअंदाज न करें",
            ],
            "en": [
                "Never apply oil, butter, or lime on acid burns",
                "Never rub eyes if contaminated with dust or battery fluid",
                "Never delay medical care for swelling or dizziness",
            ],
        },
        "audio_prompt_urls": {
            "mr": "audio/safety_first_aid_mr.mp3",
            "hi": "audio/safety_first_aid_hi.mp3",
            "en": "audio/safety_first_aid_en.mp3",
        },
    },
    {
        "id": "SAFE-BURNT-01",
        "topic_id": "burnt_condition",
        "category": "handling",
        "hazard_level": HazardLevel.WARNING,
        "pictogram": "fire_hazard_sign",
        "category_trigger": None,
        "condition_trigger": "burnt",
        "title_vernacular": {
            "mr": "जळालेला ई-कचरा: अधिकृत मार्गानेच विल्हेवाट लावा",
            "hi": "जला हुआ ई-कचरा: केवल अधिकृत रास्ते से ही रीसायकल करें",
            "en": "Burnt scrap: route only through authorized recyclers",
        },
        "summary_vernacular": {
            "mr": "जळालेल्या साहित्यात विषारी राख असते. अधिक न जाळता थेट रिसायकलरला द्या.",
            "hi": "जले हुए सामान में जहरीली राख होती है। इसे और न जलाएं, सीधे रीसाइक्लर को दें।",
            "en": "Burnt items contain toxic ash residue. Never burn further; route to EPR recyclers.",
        },
        "instructions_vernacular": {
            "mr": [
                "१. आधीच जळालेला किंवा अर्धवट जळालेला माल अधिक गरम करू नका.",
                "२. राखेत विषारी जड धातू असतात, थेट स्पर्श टाळण्यासाठी जाड हातमोजे वापरा.",
                "३. हा माल सीलबंद पोत्यात ठेवून थेट अधिकृत रिसायकलरकडे वर्ग करा.",
                "४. मोकळ्या हवेत किंवा नाल्यांजवळ जळालेला कचरा टाकू नका.",
            ],
            "hi": [
                "१. पहले से जले हुए या आंशिक जले माल को दोबारा कभी न जलाएं।",
                "२. राख में जहरीली भारी धातुएं होती हैं, सीधे छूने से बचने के लिए दस्ताने पहनें।",
                "३. इस माल को बंद बोरी में भरकर सीधे अधिकृत रीसाइक्लर को भेजें।",
                "४. खुले में या नालियों के पास जली हुई राख न फेंकें।",
            ],
            "en": [
                "1. Never attempt secondary open combustion on partially burnt scrap.",
                "2. Ash contains highly concentrated toxic heavy metal oxides; handle with PPE.",
                "3. Secure burnt remnants in heavy-duty sealed bags for EPR aggregator handover.",
                "4. Never discard residual ash in municipal dumps or water channels.",
            ],
        },
        "dos": {
            "mr": [
                "सीलबंद पोत्यात साठवा",
                "हाताळताना मास्क आणि हातमोजे वापरा",
                "थेट अधिकृत रिसायकलरकडे द्या",
            ],
            "hi": [
                "सील बंद बोरी में रखें",
                "मास्क और दस्ताने पहनकर संभालें",
                "सीधे अधिकृत रीसाइक्लर को सौंपें",
            ],
            "en": [
                "Package in sealed tear-proof sacks",
                "Wear protective respirator mask during handling",
                "Handover directly to authorized EPR recyclers",
            ],
        },
        "donts": {
            "mr": [
                "पुन्हा जाळण्याचा प्रयत्न करू नका",
                "राख उघड्यावर फेकू नका",
                "मुलांना जळालेल्या साहित्याशी खेळू देऊ नका",
            ],
            "hi": [
                "दोबारा कभी आग न लगाएं",
                "राख को खुले में न बहाएं",
                "बच्चों को जले सामान के पास न आने दें",
            ],
            "en": [
                "Never ignite or re-burn partially melted scrap",
                "Never dump ash in municipal drains",
                "Never allow bare skin contact with chemical ash",
            ],
        },
        "audio_prompt_urls": {
            "mr": "audio/safety_burnt_warning_mr.mp3",
            "hi": "audio/safety_burnt_warning_hi.mp3",
            "en": "audio/safety_burnt_warning_en.mp3",
        },
    },
]


class SafetyService:
    """Service layer for querying and managing Safety Guidance content."""

    @staticmethod
    async def seed_safety_content(db: AsyncSession | Session) -> int:
        """Seed all authoritative safety topics into the database."""
        count = 0
        for card_data in SEED_SAFETY_CARDS:
            if isinstance(db, AsyncSession):
                res = await db.execute(
                    select(SafetyContent).where(SafetyContent.id == card_data["id"])
                )
                existing = res.scalar_one_or_none()
            else:
                existing = db.execute(
                    select(SafetyContent).where(SafetyContent.id == card_data["id"])
                ).scalar_one_or_none()

            if not existing:
                content = SafetyContent(
                    id=card_data["id"],
                    category=card_data["category"],
                    hazard_level=card_data["hazard_level"],
                    pictogram_url=card_data["pictogram"],
                    audio_prompt_urls=card_data["audio_prompt_urls"],
                    title_vernacular=card_data["title_vernacular"],
                    instructions_vernacular=card_data["instructions_vernacular"],
                    dos=card_data["dos"],
                    donts=card_data["donts"],
                )
                db.add(content)
                count += 1
            else:
                existing.category = card_data["category"]
                existing.hazard_level = card_data["hazard_level"]
                existing.pictogram_url = card_data["pictogram"]
                existing.audio_prompt_urls = card_data["audio_prompt_urls"]
                existing.title_vernacular = card_data["title_vernacular"]
                existing.instructions_vernacular = card_data["instructions_vernacular"]
                existing.dos = card_data["dos"]
                existing.donts = card_data["donts"]
                count += 1

        if isinstance(db, AsyncSession):
            await db.commit()
        else:
            db.commit()
        return count

    @staticmethod
    def get_all_cards(
        language: str = "mr",
        category: str | None = None,
        db: AsyncSession | Session | None = None,
    ) -> list[SafetyCardLocalized]:
        """Return list of localized safety cards."""
        cards: list[SafetyCardLocalized] = []
        lang = language if language in ("mr", "hi", "en") else "mr"

        for card in SEED_SAFETY_CARDS:
            if category and card["category"].lower() != category.lower():
                continue

            cards.append(
                SafetyCardLocalized(
                    id=card["id"],
                    topic_id=card["topic_id"],
                    category=card["category"],
                    hazard_level=card["hazard_level"].value if isinstance(card["hazard_level"], HazardLevel) else card["hazard_level"],
                    pictogram=card["pictogram"],
                    title=card["title_vernacular"].get(lang, card["title_vernacular"]["mr"]),
                    summary=card["summary_vernacular"].get(lang, card["summary_vernacular"]["mr"]),
                    instructions=card["instructions_vernacular"].get(
                        lang, card["instructions_vernacular"]["mr"]
                    ),
                    dos=card["dos"].get(lang, card["dos"]["mr"]),
                    donts=card["donts"].get(lang, card["donts"]["mr"]),
                    audio_ref=card["audio_prompt_urls"].get(
                        lang, card["audio_prompt_urls"]["mr"]
                    ),
                    category_trigger=card.get("category_trigger"),
                    condition_trigger=card.get("condition_trigger"),
                )
            )

        return cards

    @staticmethod
    def get_card_by_topic(
        topic_id: str,
        language: str = "mr",
        db: AsyncSession | Session | None = None,
    ) -> SafetyCardLocalized | None:
        """Find a safety card by its topic_id or unique ID."""
        lang = language if language in ("mr", "hi", "en") else "mr"

        for card in SEED_SAFETY_CARDS:
            if card["topic_id"] == topic_id or card["id"] == topic_id:
                return SafetyCardLocalized(
                    id=card["id"],
                    topic_id=card["topic_id"],
                    category=card["category"],
                    hazard_level=card["hazard_level"].value if isinstance(card["hazard_level"], HazardLevel) else card["hazard_level"],
                    pictogram=card["pictogram"],
                    title=card["title_vernacular"].get(lang, card["title_vernacular"]["mr"]),
                    summary=card["summary_vernacular"].get(lang, card["summary_vernacular"]["mr"]),
                    instructions=card["instructions_vernacular"].get(
                        lang, card["instructions_vernacular"]["mr"]
                    ),
                    dos=card["dos"].get(lang, card["dos"]["mr"]),
                    donts=card["donts"].get(lang, card["donts"]["mr"]),
                    audio_ref=card["audio_prompt_urls"].get(
                        lang, card["audio_prompt_urls"]["mr"]
                    ),
                    category_trigger=card.get("category_trigger"),
                    condition_trigger=card.get("condition_trigger"),
                )
        return None

    @staticmethod
    async def record_acknowledgement(
        req: SafetyAcknowledgeRequest,
        db: AsyncSession | Session,
    ) -> SafetyAcknowledgeResponse:
        """Persist a collector safety acknowledgement record."""
        ack_time = req.acknowledged_at or datetime.now(UTC)
        ack = SafetyAcknowledgement(
            id=uuid.uuid4(),
            collector_id=req.collector_id,
            topic_id=req.topic_id,
            acknowledged_at=ack_time,
        )
        db.add(ack)
        if isinstance(db, AsyncSession):
            await db.commit()
        else:
            db.commit()

        return SafetyAcknowledgeResponse(
            success=True,
            topic_id=req.topic_id,
            collector_id=req.collector_id,
            acknowledged_at=ack_time,
            message="Safety guidance acknowledgement recorded successfully",
        )

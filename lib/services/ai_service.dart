import 'dart:convert';
import 'package:http/http.dart' as http;

class AIMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const AIMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AIService {
  static const int rateLimitMs = 1500;
  static int _lastCall = 0;

  // Local Pune Knowledge Matrix for instant and offline answers
  static final List<Map<String, dynamic>> _puneKnowledge = [
    {
      'keywords': ['sinhagad', 'sinhgad', 'sinhgarh', 'tanaji', 'kalyan darwaja', 'donje', 'lion fort'],
      'reply': '🏰 **Sinhagad Fort Travel Guide:**\n\n'
          '• **Elevation**: 4,300 ft in Haveli taluka, 30 km from Swargate.\n'
          '• **How to Reach**: PMPML bus from Swargate to Sinhagad Paytha or ghat road cab/jeep.\n'
          '• **Highlights**: Tanaji Malusare Samadhi, Kalyan Darwaza, Wind Point, and Khadakwasla view.\n'
          '• **Must-Try Local Food**: Hot Pithla-Bhakri with thecha, Kanda Bhaji, and Matka Dahi.\n'
          '• **Best Season**: July to February (lush monsoon greenery & foggy mist).'
    },
    {
      'keywords': ['shaniwar wada', 'shanivar wada', 'shaniwar', 'shanivar', 'shaniwarwada', 'peshwa', 'bajirao', 'dilli darwaza'],
      'reply': '🏛️ **Shaniwar Wada Palace Fortress Guide:**\n\n'
          '• **History**: Built in 1732 as the majestic seat of the Peshwa rulers of the Maratha Empire.\n'
          '• **Timings & Entry**: Open daily 9:30 AM – 5:30 PM (₹25 Indians / ₹300 Foreigners).\n'
          '• **Key Sights**: Dilli Darwaza with steel anti-elephant spikes, Lotus fountain, Mastani Darwaza, and archaeological gardens.\n'
          '• **Location**: Shaniwar Peth in old city, easily walkable from Dagdusheth Ganpati (5 mins walk).'
    },
    {
      'keywords': ['dagdusheth', 'dagdushet', 'dagduseth', 'halwai', 'ganpati', 'ganesh mandir', 'budhwar peth'],
      'reply': '🙏 **Shrimant Dagdusheth Halwai Ganpati Temple:**\n\n'
          '• **Significance**: One of Maharashtra\'s most revered and iconic deities, founded in 1893.\n'
          '• **Darshan Timings**: 6:00 AM to 10:30 PM daily (Free entry / VIP passes via app).\n'
          '• **Aarti Schedule**: Kakad Aarti 7:30 AM, Madhyanha Aarti 12:00 PM, Dhoop Aarti 8:00 PM.\n'
          '• **Nearby Attractions**: Shaniwar Wada (400 m), Mandai market (500 m), Tulshibaug shopping.'
    },
    {
      'keywords': ['heritage walk', 'heritage walks', 'peth', 'tulshibaug', 'mandai', 'old city', 'walking tour'],
      'reply': '🚶 **Curated Pune Heritage Walks:**\n\n'
          '• **Peths & Peshwa Legacy Walk**: 2.8 km trail covering Shaniwar Wada, Nana Wada, and Vishrambaug Wada.\n'
          '• **Camp Colonial Quarter Walk**: Discover gothic churches, Parsi bakeries, and M.G. Road.\n'
          '• **Food & Bazaars Trail**: Tulshibaug brass lanes, Phule Mandai fruit market, and Chitale Bandhu.\n'
          '• Check our interactive **Heritage Walks** section with turn-by-turn sequence maps and audio guides!'
    },
    {
      'keywords': ['lonavala', 'khandala', 'tiger point', 'bhushi', 'karla', 'bhaja'],
      'reply': '🌲 **Lonavala & Khandala Getaway Guide:**\n\n'
          '• **Distance**: 65 km from Pune (1.2 hrs via Expressway or Suburban train for ₹15).\n'
          '• **Top Attractions**: Tiger Point cliff, Bhushi Dam cascades, 2,000-year-old Karla & Bhaja Caves.\n'
          '• **Budget**: ~₹2,500 - ₹4,500 for a 2-day weekend trip.\n'
          '• **Iconic Delicacy**: Maganlal Chikki, Walnut Fudge, and hot corn bhutta in the fog.'
    },
    {
      'keywords': ['pawna', 'camping', 'lake', 'tikona', 'glamping', 'lakeside'],
      'reply': '🏕️ **Pawna Lake Camping Guide:**\n\n'
          '• **Location**: Maval taluka, 55 km from Pune near Kamshet.\n'
          '• **Package Inclusions**: Lakeside tent stay, live acoustic music, BBQ, campfire, dinner & breakfast (~₹1,200 - ₹2,200/person).\n'
          '• **Activities**: Kayaking, paddle boating, and stargazing against Tikona Fort silhouette.'
    },
    {
      'keywords': ['metro', 'transport', 'pmpml', 'bus', 'auto', 'cab', 'local train', 'airport'],
      'reply': '🚆 **Pune City Transit & Commuter Guide:**\n\n'
          '• **Pune Metro**: Line 1 (PCMC to Swargate) & Line 2 (Vanaz to Ramwadi) with ₹10–₹35 fares.\n'
          '• **PMPML Bus**: City-wide bus network with ₹50/day Pune Unlimited Pass.\n'
          '• **Local Suburban Train**: Pune Junction to Lonavala every 45 mins (ideal for fort day trips for ₹15).\n'
          '• **Airport Access**: Lohegaon Airport connects via AeroMall AC electric shuttle to Pune Station and Deccan.'
    },
    {
      'keywords': ['weather', 'season', 'when to visit', 'monsoon', 'climate', 'rain', 'temperature'],
      'reply': '⛅ **Best Time to Visit Pune:**\n\n'
          '• **Monsoon (July – Sept)**: Peak Sahyadri beauty! Verdant hills, misty waterfalls at Sinhagad, Tamhini & Lonavala (22°C - 28°C).\n'
          '• **Winter (Oct – Feb)**: Pleasant, crisp weather perfect for heritage walks, cycling and fort trekking (12°C - 28°C).\n'
          '• **Ganeshotsav (Sept)**: World-famous 10-day cultural spectacle with Dhol-Tasha troupes and illuminated pandals.'
    },
    {
      'keywords': ['misal', 'food', 'eat', 'mastani', 'bakarwadi', 'katakirr', 'bedekar', 'goodluck', 'thali'],
      'reply': '🍲 **Iconic Pune Food Trail & Culinary Hotspots:**\n\n'
          '• **Puneri Misal**: KataKirr (Karve Rd), Bedekar Tea Stall (Narayan Peth), Vaidya Upahar Gruha.\n'
          '• **Sujata Mastani**: World-famous thick mango and sitaphal Mastani ice-cream milkshakes.\n'
          '• **Chitale Bandhu**: Crispy Bakarwadi and Mango Barfi (Bajirao Rd / Deccan).\n'
          '• **Heritage Cafes**: Goodluck Cafe (FC Road - Bun Maska & Irani Chai).\n'
          '• **Authentic Thali**: Shabaree (FC Road) & Sukanta (Deccan).'
    },
    {
      'keywords': ['darshan', 'city tour', 'sightseeing', 'pune darshan', 'aga khan', 'parvati'],
      'reply': '🚌 **Pune Darshan & Heritage Bus Tour:**\n\n'
          '• **Full-Day AC Coach**: Covers Shaniwar Wada, Aga Khan Palace, Dagdusheth Ganpati, Parvati Hill & Saras Baug (~₹499/person).\n'
          '• **Timings**: 8:00 AM to 7:00 PM daily.\n'
          '• **Pickups**: Pune Station, Swargate, Deccan Gymkhana, and Wakad.\n'
          '• You can book directly with interactive 28-seat selection under the **Pune Darshan** tab!'
    },
    {
      'keywords': ['torna', 'rajgad', 'trek', 'hiking', 'forts', 'prachandagad', 'bale killa', 'lohagad', 'visapur'],
      'reply': '⛰️ **Top Sahyadri Fort Treks around Pune:**\n\n'
          '• **Torna Fort (Prachandagad)**: First fort captured by Shivaji Maharaj at age 16 (4,603 ft, challenging trek from Velhe).\n'
          '• **Rajgad Fort**: Former capital of Maratha Empire with Suvela Machi and Bale Killa citadel.\n'
          '• **Lohagad & Visapur**: Easy-to-moderate twin forts near Malavli station.\n'
          '• **Safety Rule**: Always carry 2L hydration water and wear rubber-grip shoes.'
    },
    {
      'keywords': ['lavasa', 'mulshi', 'tamhini', 'waterfall', 'devkund', 'plus valley'],
      'reply': '🌊 **Mulshi, Tamhini Ghat & Lavasa Circuit:**\n\n'
          '• **Distance**: 45–70 km from Pune via Chandani Chowk / Pirangut.\n'
          '• **Highlights**: Mulshi Lake dam view, Plus Valley canyon in Tamhini, Devkund Waterfall trek.\n'
          '• **Monsoon Note**: Tamhini Ghat comes alive with hundreds of cascading roadside waterfalls from July to September.'
    },
    {
      'keywords': ['budget', 'under 2000', 'cheap', 'cost', 'expenses'],
      'reply': '💰 **1-Day Pune Budget Trip under ₹2,000:**\n\n'
          '1. **Local Train to Malavli / Lonavala**: ₹15\n'
          '2. **Lohagad Fort Entry & Trek**: ₹25\n'
          '3. **Bhaja Caves Exploration**: ₹25\n'
          '4. **Hot Pithla Bhakri & Tea Lunch**: ₹150\n'
          '5. **Maganlal Chikki Souvenir**: ₹200\n'
          '**Total spent**: ~₹415 per person! Use our **Budget Planner** tab for custom breakdowns.'
    }
  ];

  Future<String> askAssistant(String question, {String? edgeFunctionUrl}) async {
    final clean = question.trim();
    if (clean.isEmpty) return 'Please ask a question about Pune travel, treks, or tours.';

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastCall < rateLimitMs) {
      await Future.delayed(const Duration(milliseconds: 250));
    }
    _lastCall = DateTime.now().millisecondsSinceEpoch;

    // 1. Try backend/edge function if configured
    if (edgeFunctionUrl != null && edgeFunctionUrl.isNotEmpty) {
      try {
        final res = await http.post(
          Uri.parse(edgeFunctionUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'prompt': clean}),
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['reply'] != null) return data['reply'].toString();
        }
      } catch (_) {}
    }

    // 2. Local Pune travel intelligence matrix
    final lower = clean.toLowerCase();
    for (final item in _puneKnowledge) {
      final List<String> keywords = (item['keywords'] as List).cast<String>();
      if (keywords.any((kw) => lower.contains(kw))) {
        return item['reply'] as String;
      }
    }

    // 3. Fallback response
    return 'Namaste! 🙏 I\'m **PunekarBot**, your Pune travel guide.\n\n'
        'I can assist you with:\n'
        '• **Sinhagad, Torna, Rajgad & Lohagad Fort Treks** ⛰️\n'
        '• **Lonavala, Pawna Lake & Tamhini Getaways** 🌲\n'
        '• **Authentic Puneri Misal, Sujata Mastani & Food Spots** 🍲\n'
        '• **Pune Darshan AC Bus Tours & Seat Booking** 🚌\n\n'
        'Feel free to ask for trek itineraries, food recommendations, or budget tips!';
  }
}

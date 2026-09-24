import 'package:flutter/material.dart';

void main() {
  runApp(const KabadiwalaApp());
}

class KabadiwalaApp extends StatelessWidget {
  const KabadiwalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kabadiwala Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF047857), // Forest Green
          primary: const Color(0xFF047857),
        ),
        useMaterial3: true,
      ),
      home: const CollectorHomeScreen(),
    );
  }
}

class CollectorHomeScreen extends StatelessWidget {
  const CollectorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('कबाडीवाला कनेक्ट'),
        actions: [
          // Speaker button on every screen for low-literacy read aloud
          IconButton(
            icon: const Icon(Icons.volume_up, size: 32),
            tooltip: 'ऐका (Listen)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('स्क्रीनवरील माहिती वाचून दाखवली जात आहे...'),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Offline status badge with pictorial cues
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_queue, color: Colors.amber, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'माहिती सुरक्षित आहे (ऑफलाइन मोड)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Large 56dp+ action buttons
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildBigActionButton(
                      context,
                      icon: Icons.add_a_photo,
                      label: 'नवीन माल\nजोडा',
                      color: Colors.emerald,
                      onTap: () {},
                    ),
                    _buildBigActionButton(
                      context,
                      icon: Icons.currency_rupee,
                      label: 'आजचे भाव\nपहा',
                      color: Colors.teal,
                      onTap: () {},
                    ),
                    _buildBigActionButton(
                      context,
                      icon: Icons.qr_code_scanner,
                      label: 'माल जमा करा\n(Handover)',
                      color: Colors.blue,
                      onTap: () {},
                    ),
                    _buildBigActionButton(
                      context,
                      icon: Icons.account_balance_wallet,
                      label: 'माझा हिशोब\n(Ledger)',
                      color: Colors.deepOrange,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.shade50,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.shade300, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color.shade800),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

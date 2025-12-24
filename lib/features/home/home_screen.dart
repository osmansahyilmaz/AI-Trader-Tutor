import 'package:ai_trader_tutor/features/analysis/providers/analysis_providers.dart';
import 'package:ai_trader_tutor/features/analysis/screens/analysis_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_trader_tutor/features/history/history_screen.dart';
import 'package:ai_trader_tutor/features/settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSymbol;
  String _selectedTimeframe = '1h';
  bool _isLoading = false;

  // Hardcoded for MVP from symbol_universe.json
  // Ideally this should be loaded from a JSON asset or API
  final List<Map<String, String>> _cryptoSymbols = [
    {'symbol': 'BTCUSDT', 'display': 'BTC/USDT'},
    {'symbol': 'ETHUSDT', 'display': 'ETH/USDT'},
    {'symbol': 'BNBUSDT', 'display': 'BNB/USDT'},
    {'symbol': 'SOLUSDT', 'display': 'SOL/USDT'},
    {'symbol': 'XRPUSDT', 'display': 'XRP/USDT'},
  ];

  final List<Map<String, String>> _fxSymbols = [
    {'symbol': 'EUR/USD', 'display': 'EUR/USD'},
    {'symbol': 'USD/JPY', 'display': 'USD/JPY'},
    {'symbol': 'GBP/USD', 'display': 'GBP/USD'},
    {'symbol': 'USD/TRY', 'display': 'USD/TRY'},
  ];

  List<Map<String, String>> get _allSymbols => [..._cryptoSymbols, ..._fxSymbols];

  final List<String> _timeframes = ['15m', '1h', '4h', '1d'];

  Future<void> _analyze() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(analysisRepositoryProvider);
      final requestId = const Uuid().v4();

      final result = await repository.analyzeRequest(
        symbol: _selectedSymbol!,
        timeframe: _selectedTimeframe,
        requestId: requestId,
      );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AnalysisResultScreen(analysis: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trader AI Tutor'),
        actions: [


          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),


          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Piyasa Analizi Başlat',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Symbol Picker
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Sembol Seçin',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                value: _selectedSymbol,
                items: _allSymbols.map((s) {
                  return DropdownMenuItem(
                    value: s['symbol'],
                    child: Text(s['display']!),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedSymbol = value),
                validator: (value) => value == null ? 'Lütfen bir sembol seçin' : null,
              ),
              const SizedBox(height: 16),

              // Timeframe Picker
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Zaman Dilimi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                value: _selectedTimeframe,
                items: _timeframes.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedTimeframe = value!),
              ),
              const SizedBox(height: 32),

              // Analyze Button
              FilledButton.icon(
                onPressed: _isLoading ? null : _analyze,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      ) 
                    : const Icon(Icons.analytics),
                label: Text(_isLoading ? 'Analiz Yapılıyor...' : 'Analiz Et'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const Spacer(),
              const Text(
                'Günlük limitiniz: 1 analiz (MVP)',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

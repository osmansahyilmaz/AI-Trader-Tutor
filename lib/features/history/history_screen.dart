import 'package:ai_trader_tutor/features/analysis/models/analysis_models.dart';
import 'package:ai_trader_tutor/features/analysis/providers/analysis_providers.dart';
import 'package:ai_trader_tutor/features/analysis/screens/analysis_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(analysisHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş Analizler'),
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(child: Text('Henüz analiz bulunmuyor.'));
          }
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final analysis = history[index];
              return _buildHistoryItem(context, analysis);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, AnalysisResponse analysis) {
    final payload = analysis.payload;
    final dateFmt = DateFormat('dd MMM yyyy HH:mm').format(analysis.createdAt.toLocal());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTrendColor(payload.trendState).withOpacity(0.2),
          child: Icon(
            _getTrendIcon(payload.trendState),
            color: _getTrendColor(payload.trendState),
          ),
        ),
        title: Text('${payload.symbol} (${payload.timeframe})'),
        subtitle: Text(dateFmt),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AnalysisResultScreen(analysis: analysis),
            ),
          );
        },
      ),
    );
  }

  Color _getTrendColor(String state) {
    switch (state) {
      case 'bullish':
        return Colors.green;
      case 'bearish':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTrendIcon(String state) {
    switch (state) {
      case 'bullish':
        return Icons.trending_up;
      case 'bearish':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }
}

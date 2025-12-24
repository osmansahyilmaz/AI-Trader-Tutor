import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/analysis_models.dart';

class AnalysisResultScreen extends ConsumerWidget {
  final AnalysisResponse analysis;

  const AnalysisResultScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = analysis.payload;
    final explanation = analysis.explanation;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${payload.symbol} (${payload.timeframe})'),
        actions: [
          Chip(
            label: Text(payload.trendState.toUpperCase()),
            backgroundColor: _getTrendColor(payload.trendState),
            labelStyle: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            _buildHeader(context, payload),
            const SizedBox(height: 16),

            // 4 Sections
            _buildSectionCard(
              context,
              title: 'Özet',
              content: explanation.summary,
              icon: Icons.summarize,
            ),
            _buildSectionCard(
              context,
              title: 'Teknik Göstergeler',
              content: explanation.indicators,
              icon: Icons.show_chart,
              child: _buildIndicatorsDetail(payload),
            ),
            _buildSectionCard(
              context,
              title: 'Senaryolar',
              content: explanation.scenarios,
              icon: Icons.alt_route,
              child: _buildLevelsDetail(payload),
            ),
            _buildSectionCard(
              context,
              title: 'Risk Notu',
              content: explanation.riskNote,
              icon: Icons.warning_amber,
              color: Colors.orange.shade50,
              textColor: Colors.orange.shade900,
            ),

            const SizedBox(height: 24),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'YASAL UYARI: Bu uygulama sadece eğitim amaçlıdır. Yatırım tavsiyesi değildir. Finansal piyasalar yüksek risk içerir.',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AnalysisPayload payload) {
    final priceFmt = NumberFormat.currency(symbol: '', decimalDigits: 2).format(payload.currentPrice);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fiyat', style: Theme.of(context).textTheme.labelLarge),
                Text(priceFmt, style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Yapı', style: Theme.of(context).textTheme.labelLarge),
                Text(
                  payload.structure.state.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getStructureColor(payload.structure.state),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    Widget? child,
    Color? color,
    Color? textColor,
  }) {
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor ?? Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor),
            ),
            if (child != null) ...[
              const SizedBox(height: 12),
              child,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorsDetail(AnalysisPayload payload) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text('Detaylar:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('RSI: ${payload.rsi.value.toStringAsFixed(2)} (${payload.rsi.state})'),
        Text('ATR: ${payload.atr.value.toStringAsFixed(4)} (%${payload.atr.percent.toStringAsFixed(2)})'),
        Text('EMA20: ${payload.ema.ema20.toStringAsFixed(2)}'),
        Text('EMA50: ${payload.ema.ema50.toStringAsFixed(2)}'),
        Text('EMA200: ${payload.ema.ema200.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildLevelsDetail(AnalysisPayload payload) {
    if (payload.levels.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Önemli Seviyeler:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ...payload.levels.map((l) => Text(
              '${l.type == 'support' ? 'Destek' : 'Direnç'}: ${l.price.toStringAsFixed(2)} (${l.touches} temas)',
              style: TextStyle(
                color: l.type == 'support' ? Colors.green : Colors.red,
              ),
            )),
      ],
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

  Color _getStructureColor(String state) {
    switch (state) {
      case 'uptrend':
        return Colors.green;
      case 'downtrend':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

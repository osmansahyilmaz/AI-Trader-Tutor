class AnalysisResponse {
  final String analysisId;
  final DateTime createdAt;
  final String payloadVersion;
  final AnalysisPayload payload;
  final Explanation explanation;

  AnalysisResponse({
    required this.analysisId,
    required this.createdAt,
    required this.payloadVersion,
    required this.payload,
    required this.explanation,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      analysisId: json['analysisId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      payloadVersion: json['payload_version'] as String,
      payload: AnalysisPayload.fromJson(json['analysis_payload'] as Map<String, dynamic>),
      explanation: Explanation.fromJson(json['explanation'] as Map<String, dynamic>),
    );
  }
}

class AnalysisPayload {
  final String symbol;
  final String timeframe;
  final double currentPrice;
  final EmaIndicators ema;
  final String trendState;
  final RsiIndicator rsi;
  final AtrIndicator atr;
  final Structure structure;
  final List<Level> levels;

  AnalysisPayload({
    required this.symbol,
    required this.timeframe,
    required this.currentPrice,
    required this.ema,
    required this.trendState,
    required this.rsi,
    required this.atr,
    required this.structure,
    required this.levels,
  });

  factory AnalysisPayload.fromJson(Map<String, dynamic> json) {
    return AnalysisPayload(
      symbol: json['symbol'] as String,
      timeframe: json['timeframe'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      ema: EmaIndicators.fromJson(json['ema'] as Map<String, dynamic>),
      trendState: json['trend_state'] as String,
      rsi: RsiIndicator.fromJson(json['rsi'] as Map<String, dynamic>),
      atr: AtrIndicator.fromJson(json['atr'] as Map<String, dynamic>),
      structure: Structure.fromJson(json['structure'] as Map<String, dynamic>),
      levels: (json['levels'] as List<dynamic>)
          .map((e) => Level.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class EmaIndicators {
  final double ema20;
  final double ema50;
  final double ema200;

  EmaIndicators({
    required this.ema20,
    required this.ema50,
    required this.ema200,
  });

  factory EmaIndicators.fromJson(Map<String, dynamic> json) {
    return EmaIndicators(
      ema20: (json['ema20'] as num).toDouble(),
      ema50: (json['ema50'] as num).toDouble(),
      ema200: (json['ema200'] as num).toDouble(),
    );
  }
}

class RsiIndicator {
  final double value;
  final String state;

  RsiIndicator({required this.value, required this.state});

  factory RsiIndicator.fromJson(Map<String, dynamic> json) {
    return RsiIndicator(
      value: (json['value'] as num).toDouble(),
      state: json['state'] as String,
    );
  }
}

class AtrIndicator {
  final double value;
  final double percent;

  AtrIndicator({required this.value, required this.percent});

  factory AtrIndicator.fromJson(Map<String, dynamic> json) {
    return AtrIndicator(
      value: (json['value'] as num).toDouble(),
      percent: (json['percent'] as num).toDouble(),
    );
  }
}

class Structure {
  final String state;
  final List<Pivot> recentPivots;

  Structure({required this.state, required this.recentPivots});

  factory Structure.fromJson(Map<String, dynamic> json) {
    return Structure(
      state: json['state'] as String,
      recentPivots: (json['recent_pivots'] as List<dynamic>)
          .map((e) => Pivot.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Pivot {
  final String type;
  final double price;
  final int t;

  Pivot({required this.type, required this.price, required this.t});

  factory Pivot.fromJson(Map<String, dynamic> json) {
    return Pivot(
      type: json['type'] as String,
      price: (json['price'] as num).toDouble(),
      t: json['t'] as int,
    );
  }
}

class Level {
  final String type;
  final double price;
  final double distancePercent;
  final int touches;

  Level({
    required this.type,
    required this.price,
    required this.distancePercent,
    required this.touches,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      type: json['type'] as String,
      price: (json['price'] as num).toDouble(),
      distancePercent: (json['distance_percent'] as num).toDouble(),
      touches: json['touches'] as int,
    );
  }
}

class Explanation {
  final String summary;
  final String indicators;
  final String scenarios;
  final String riskNote;

  Explanation({
    required this.summary,
    required this.indicators,
    required this.scenarios,
    required this.riskNote,
  });

  factory Explanation.fromJson(Map<String, dynamic> json) {
    return Explanation(
      summary: json['summary'] as String,
      indicators: json['indicators'] as String,
      scenarios: json['scenarios'] as String,
      riskNote: json['risk_note'] as String,
    );
  }
}

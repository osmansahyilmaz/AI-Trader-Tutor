import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/analysis_repository.dart';
import '../models/analysis_models.dart';

final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  return AnalysisRepository(Supabase.instance.client);
});

final analysisHistoryProvider = FutureProvider<List<AnalysisResponse>>((ref) async {
  final repository = ref.watch(analysisRepositoryProvider);
  return repository.getAnalysesHistory();
});

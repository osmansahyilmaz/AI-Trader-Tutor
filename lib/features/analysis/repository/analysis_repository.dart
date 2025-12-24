import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_trader_tutor/core/constants.dart';
import '../models/analysis_models.dart';

class AnalysisException implements Exception {
  final String message;
  final String? code;

  AnalysisException(this.message, {this.code});

  @override
  String toString() => 'AnalysisException: $message (code: $code)';
}

class AnalysisRepository {
  final SupabaseClient _client;

  AnalysisRepository(this._client);

  Future<AnalysisResponse> analyzeRequest({
    required String symbol,
    required String timeframe,
    required String requestId,
    String? assetClass,
  }) async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        throw AnalysisException('User not authenticated', code: '401');
      }

      final url = Uri.parse('${AppConstants.supabaseUrl}/functions/v1/analyzeRequest');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'apikey': AppConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
        body: jsonEncode({
          'symbol': symbol,
          'timeframe': timeframe,
          'requestId': requestId,
          if (assetClass != null) 'assetClass': assetClass,
           // Explicitly sending user_id as requested by user pattern, 
           // although usually extracted from token on backend.
          'user_id': session.user.id, 
        }),
      );

      if (response.statusCode != 200) {
         Map<String, dynamic> errorData = {};
         try {
           errorData = jsonDecode(response.body);
         } catch (_) {}
         
         final errorMsg = errorData['error'] ?? 'Unknown error';
         
         if (response.statusCode == 402) {
           throw AnalysisException('insufficient-funds', code: '402');
         }
         
         throw AnalysisException(errorMsg, code: response.statusCode.toString());
      }

      final data = jsonDecode(response.body);
      return AnalysisResponse.fromJson(data);

    } catch (e) {
      if (e is AnalysisException) rethrow;
      throw AnalysisException(e.toString());
    }
  }

  Future<AnalysisResponse> getAnalysis(String analysisId) async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
         throw AnalysisException('User not authenticated', code: '401');
      }

      final url = Uri.parse('${AppConstants.supabaseUrl}/functions/v1/getAnalysis?id=$analysisId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'apikey': AppConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.statusCode != 200) {
         Map<String, dynamic> errorData = {};
         try {
           errorData = jsonDecode(response.body);
         } catch (_) {}
         
         final errorMsg = errorData['error'] ?? 'Unknown error';
         throw AnalysisException(errorMsg, code: response.statusCode.toString());
      }
      
      final data = jsonDecode(response.body);
      return AnalysisResponse.fromJson(data);

    } catch (e) {
      if (e is AnalysisException) rethrow;
      throw AnalysisException(e.toString());
    }
  }

  Future<List<AnalysisResponse>> getAnalysesHistory() async {
    try {
      final data = await _client
          .from('analyses')
          .select()
          .order('created_at', ascending: false)
          .limit(50); // MVP limit

      return (data as List).map((row) {
        return AnalysisResponse.fromJson({
          'analysisId': row['id'],
          'createdAt': row['created_at'],
          'payload_version': row['payload_version'],
          'analysis_payload': row['analysis_payload'],
          'explanation': row['explanation'],
        });
      }).toList();
    } catch (e) {
      throw AnalysisException(e.toString());
    }
  }
}

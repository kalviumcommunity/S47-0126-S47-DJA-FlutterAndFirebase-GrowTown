import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

class CloudFunctionsService {
  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  /// Calls the greetUser Cloud Function
  /// Returns a greeting message for the given user name
  static Future<String> greetUser(String name) async {
    try {
      final callable = _functions.httpsCallable('greetUser');

      final result = await callable.call({'name': name});

      // Extract the message from the result
      final data = result.data as Map<dynamic, dynamic>;
      final message = data['message'] as String;

      return message;
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Cloud Function error: ${e.message}');
    } catch (e) {
      throw Exception('Error calling Cloud Function: $e');
    }
  }

  /// Gets the full greeting response from the Cloud Function
  /// Returns a map with message, timestamp, and userId
  static Future<Map<String, dynamic>> getFullGreeting(String name) async {
    try {
      final callable = _functions.httpsCallable('greetUser');

      final result = await callable.call({'name': name});
      final data = result.data as Map<dynamic, dynamic>;

      return {
        'message': data['message'] as String,
        'timestamp': data['timestamp'] as String,
        'userId': data['userId'] as String,
      };
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Cloud Function error: ${e.message}');
    } catch (e) {
      throw Exception('Error calling Cloud Function: $e');
    }
  }
}

import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_exception.dart';
import 'failure.dart';

class ErrorHandler {
  ErrorHandler._();

  static Failure handle(Object error) {
    if (error is AuthApiException) {
      return AuthFailure(_mapAuthError(error.message));
    }
    if (error is PostgrestException) {
      return ServerFailure(error.message);
    }
    if (error is AppException) {
      return ServerFailure(error.message);
    }
    return const UnknownFailure();
  }

  static String _mapAuthError(String rawMessage) {
    final msg = rawMessage.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Email ya password ghalat hai';
    }
    if (msg.contains('email not confirmed')) {
      return 'Pehle apna email verify karein';
    }
    if (msg.contains('user already registered')) {
      return 'Ye email pehle se registered hai';
    }
    if (msg.contains('otp')) {
      return 'OTP ghalat ya expire ho chuka hai';
    }
    return rawMessage;
  }
}
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Result model for RC verification
class RCVerificationResult {
  final bool success;
  final String? ownerName;
  final String? vehicleClass;
  final String? fuelType;
  final String? makerModel;
  final String? registrationDate;
  final String? rcExpiryDate;
  final String? insuranceUpto;
  final String? insuranceCompany;
  final String? chassisNumber;
  final String? engineNumber;
  final String? fitnessUpto;
  final String? vehicleColor;
  final String? registrationAuthority;
  final String? vehicleNumber;
  final String? errorMessage;
  final Map<String, dynamic>? rawData;

  const RCVerificationResult({
    required this.success,
    this.ownerName,
    this.vehicleClass,
    this.fuelType,
    this.makerModel,
    this.registrationDate,
    this.rcExpiryDate,
    this.insuranceUpto,
    this.insuranceCompany,
    this.chassisNumber,
    this.engineNumber,
    this.fitnessUpto,
    this.vehicleColor,
    this.registrationAuthority,
    this.vehicleNumber,
    this.errorMessage,
    this.rawData,
  });

  factory RCVerificationResult.fromCashfreeResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    // Cashfree nests details under "data" -> various keys
    final details = data['data'] as Map<String, dynamic>? ?? data;

    return RCVerificationResult(
      success: json['success'] == true || data['status'] == 'VALID',
      ownerName: details['owner_name'] as String?,
      vehicleClass: details['vehicle_class'] as String?,
      fuelType: details['fuel_type'] as String?,
      makerModel: details['maker_model'] as String?,
      registrationDate: details['registration_date'] as String?,
      rcExpiryDate: details['rc_expiry_date'] as String?,
      insuranceUpto: details['insurance_upto'] as String?,
      insuranceCompany: details['insurance_company'] as String?,
      chassisNumber: details['chassis_number'] as String?,
      engineNumber: details['engine_number'] as String?,
      fitnessUpto: details['fitness_upto'] as String?,
      vehicleColor: details['vehicle_color'] as String?,
      registrationAuthority: details['registration_authority'] as String?,
      vehicleNumber: details['vehicle_number'] as String?,
      rawData: details,
    );
  }

  factory RCVerificationResult.error(String message) {
    return RCVerificationResult(success: false, errorMessage: message);
  }
}

/// Service to verify vehicle RC numbers via backend API.
class RCVerificationService {
  // TODO: Update this to your deployed backend URL
  static const String _backendBaseUrl =
      'http://10.0.2.2:8000'; // Android emulator -> host
  static const String _backendBaseUrlWeb = 'http://localhost:8000';

  /// Verifies a vehicle RC number by calling the backend,
  /// which securely proxies the request to Cashfree.
  static Future<RCVerificationResult> verifyRC(String vehicleNumber) async {
    final number = vehicleNumber.trim().toUpperCase();
    if (number.isEmpty) {
      return RCVerificationResult.error('Please enter a vehicle number.');
    }

    // Basic Indian vehicle registration format validation
    final rcPattern = RegExp(r'^[A-Z]{2}\d{1,2}[A-Z]{0,3}\d{1,4}$');
    if (!rcPattern.hasMatch(number.replaceAll(' ', ''))) {
      return RCVerificationResult.error(
        'Invalid vehicle number format. Example: KA01AB1234',
      );
    }

    const baseUrl = kIsWeb ? _backendBaseUrlWeb : _backendBaseUrl;
    final url = Uri.parse('$baseUrl/api/v1/equipment/verify-rc/');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'vehicle_number': number}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return RCVerificationResult.fromCashfreeResponse(data);
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return RCVerificationResult.error(
          data['error'] as String? ??
              'Verification failed (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('RC verification error: $e');
      return RCVerificationResult.error(
        'Could not connect to verification service. Please try again.',
      );
    }
  }
}

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:paystack_flutter_sdk/paystack_flutter_sdk.dart';

import 'paystack_web_bridge_stub.dart'
    if (dart.library.js_interop) 'paystack_web_bridge.dart';

import '../../../config/paystack_config.dart';

class PaystackPaymentResult {
  const PaystackPaymentResult({
    required this.status,
    this.reference,
    this.message,
  });

  final String status;
  final String? reference;
  final String? message;

  bool get isSuccess => status == 'success';
  bool get isCancelled => status == 'cancelled';
}

class PaystackPaymentService {
  PaystackPaymentService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;
  final Paystack _paystack = Paystack();

  Future<PaystackPaymentResult> payInvoice(String invoiceId) async {
    // Mobile checkout uses the public key. Web checkout uses the
    // server-generated access_code and Paystack InlineJS.
    if (!kIsWeb && !PaystackConfig.isConfigured) {
      throw StateError(
        'Paystack public key is not configured. '
        'Run the app with '
        '--dart-define=PAYSTACK_PUBLIC_KEY=YOUR_PUBLIC_KEY.',
      );
    }

    try {
      // ------------------------------------------------------------
      // 1. Ask Firebase to initialize the Paystack transaction.
      // ------------------------------------------------------------
      final initialize = _functions.httpsCallable(
        'initializePaystackPayment',
      );

      final initialized = await initialize.call<Map<String, dynamic>>({
        'invoiceId': invoiceId,
      });

      final payload = Map<String, dynamic>.from(initialized.data);

      final accessCode = payload['accessCode']?.toString() ?? '';
      final serverReference = payload['reference']?.toString() ?? '';

      if (accessCode.isEmpty || serverReference.isEmpty) {
        throw StateError(
          'Paystack did not return a valid checkout session.',
        );
      }

      // ------------------------------------------------------------
      // 2. Complete the transaction.
      // Web uses Paystack InlineJS; Android/iOS uses the Flutter SDK.
      // ------------------------------------------------------------
      String status;
      String reference;
      String? sdkMessage;

      if (kIsWeb) {
        final success = await resumePaystackTransaction(accessCode);
        status = success ? 'success' : 'cancelled';
        reference = serverReference;
        sdkMessage = success ? null : 'Payment was cancelled.';
      } else {
        final ready = await _paystack.initialize(
          PaystackConfig.publicKey,
          false,
        );

        if (!ready) {
          throw StateError('Unable to initialise Paystack checkout.');
        }

        final response = await _paystack.launch(accessCode);
        status = response.status.toString().toLowerCase();
        final sdkReference = response.reference.toString().trim();
        reference = sdkReference.isEmpty ? serverReference : sdkReference;
        sdkMessage = response.message.toString();
      }

      // ------------------------------------------------------------
      // 3. User cancelled / checkout reported failure.
      // ------------------------------------------------------------
      if (status != 'success') {
        return PaystackPaymentResult(
          status: status.isEmpty ? 'failed' : status,
          reference: reference,
          message: sdkMessage,
        );
      }

      // ------------------------------------------------------------
      // 5. NEVER trust the Flutter SDK alone.
      //
      // Firebase verifies the transaction directly with Paystack.
      // ------------------------------------------------------------
      final verify = _functions.httpsCallable(
        'verifyPaystackPayment',
      );

      final verified = await verify.call<Map<String, dynamic>>({
        'reference': reference,
      });

      final verification = Map<String, dynamic>.from(
        verified.data,
      );

      return PaystackPaymentResult(
        status: verification['status']?.toString() ?? 'failed',
        reference:
            verification['reference']?.toString() ?? reference,
        message: verification['message']?.toString(),
      );
    } on FirebaseFunctionsException catch (error) {
      throw StateError(
        error.message ??
            'Unable to process the Paystack payment.',
      );
    } on PlatformException catch (error) {
      throw StateError(
        error.message ??
            'Paystack checkout could not be opened.',
      );
    }
  }
}
/// Public Paystack configuration.
///
/// The public key is safe to ship in the mobile application. The Paystack
/// secret key is intentionally NOT stored here; it lives in Firebase Secret
/// Manager and is only used by Cloud Functions.
class PaystackConfig {
  const PaystackConfig._();

  static const publicKey = String.fromEnvironment(
    'PAYSTACK_PUBLIC_KEY',
    defaultValue: 'pk_test_REPLACE_ME',
  );

  static bool get isConfigured =>
      (publicKey.startsWith('pk_test_') || publicKey.startsWith('pk_live_')) &&
      publicKey != 'pk_test_REPLACE_ME';
}

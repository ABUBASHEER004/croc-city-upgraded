import 'dart:js_interop';

@JS('crocCityPaystackResume')
external JSPromise<JSBoolean> _resumePaystackTransaction(String accessCode);

Future<bool> resumePaystackTransaction(String accessCode) async {
  final result = await _resumePaystackTransaction(accessCode).toDart;
  return result.toDart;
}

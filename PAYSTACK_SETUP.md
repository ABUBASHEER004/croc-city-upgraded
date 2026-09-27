# Croc City Paystack + Premium Player Dashboard

This project now contains a Paystack payment flow backed by Firebase Cloud Functions and a refreshed premium player dashboard.

## What was added

- `paystack_flutter_sdk` for Android/iOS checkout.
- `cloud_functions` to call secure Firebase backend functions.
- `functions/initializePaystackPayment` to create a Paystack checkout session.
- `functions/verifyPaystackPayment` to verify a successful transaction on the server and record it in Firestore.
- `functions/paystackWebhook` to process Paystack `charge.success` events and prevent missed payments.
- Idempotent payment records using `paystack_<reference>` document IDs.
- Parent finance invoice cards now show **Pay now** for outstanding invoices.
- Premium player dashboard hero with stadium imagery and player/profile photography, with a safe placeholder fallback.
- Android `FlutterFragmentActivity` required by Paystack's current Flutter SDK integration.

## 1. Install Flutter dependencies

From the project root:

```bash
flutter pub get
```

## 2. Configure the Paystack public key

Do not put the Paystack secret key in Flutter.

Run the app with your Paystack **public key**:

```bash
flutter run --dart-define=PAYSTACK_PUBLIC_KEY=pk_test_xxxxxxxxxxxxxxxxx
```

For production, use your live public key:

```bash
flutter run --release --dart-define=PAYSTACK_PUBLIC_KEY=pk_live_xxxxxxxxxxxxxxxxx
```

The public key is intentionally passed to Flutter. The secret key belongs only in Firebase Secret Manager.

## 3. Configure the Paystack secret key in Firebase

From the project root:

```bash
firebase functions:secrets:set PAYSTACK_SECRET_KEY
```

Paste the Paystack **secret key** when prompted.

Then deploy the functions:

```bash
firebase deploy --only functions
```

The Firebase project in this app is already configured in `.firebaserc`.

## 4. Configure the Paystack webhook

After deployment, Firebase will print the URL for `paystackWebhook`.

In Paystack Dashboard, add that HTTPS function URL as your webhook URL.

The webhook validates Paystack's `x-paystack-signature` using HMAC SHA-512 before processing the event.

## 5. Test payment flow

Use Paystack **test mode** first.

1. Create an invoice in the academy finance area.
2. Make sure the invoice is linked to a parent account.
3. Sign in as that parent.
4. Open **Fees & Payments**.
5. Tap **Pay now** on an outstanding invoice.
6. Complete the Paystack test payment.
7. The app sends the returned reference to Firebase.
8. Firebase verifies the transaction with Paystack.
9. Firebase records the payment and updates the invoice balance.
10. The webhook provides a second server-side confirmation path.

## Security model

The Flutter app never receives or stores `PAYSTACK_SECRET_KEY`.

The backend determines the amount from the Firestore invoice instead of trusting an amount sent by the client. It also checks that the signed-in parent owns the invoice, verifies the Paystack transaction, checks the verified amount against the outstanding balance, and uses an idempotent reference before recording payment.

## Important platform note

Paystack's official Flutter SDK currently targets Android and iOS. The app therefore blocks the native Paystack checkout on Flutter Web rather than pretending the native SDK is supported there. A separate web checkout can be added later if needed.

## Web checkout

The web build uses Paystack InlineJS v2 with the server-initialized `access_code`. The Paystack Secret Key stays in Firebase Secret Manager. The Flutter web app loads `https://js.paystack.co/v2/inline.js`, opens the Paystack popup with `resumeTransaction(accessCode)`, and then calls the Firebase verification function before treating the invoice as paid.

Build the web app with:

```bash
flutter build web --release --dart-define=PAYSTACK_PUBLIC_KEY=pk_live_YOUR_PUBLIC_KEY
```

The web resume flow itself does not expose the Secret Key; the Secret Key remains a Firebase Functions secret.

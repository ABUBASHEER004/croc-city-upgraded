# First Admin Setup

Croc City does **not** expose Administrator registration on the public registration screen.
The first administrator should be created from a trusted machine with the Firebase Admin SDK.
Firebase recommends custom claims for role-based access control; those claims are set only from a privileged server environment. See the official Firebase documentation for custom claims and Security Rules.

## 1. Create a Firebase service-account key

In the Firebase/Google Cloud console for the `croc-city-football-academy` project, create a service-account key and download the JSON file to a secure location outside this Flutter project.

**Do not commit the JSON key to Git or put it in `assets/`.**

## 2. Install the admin tool

From this project directory:

```powershell
cd tools
npm install
```

## 3. Create the first administrator

PowerShell example:

```powershell
$env:FIREBASE_SERVICE_ACCOUNT="C:\secure\croc-city-service-account.json"
$env:ADMIN_EMAIL="admin@example.com"
$env:ADMIN_PASSWORD="Choose-A-Strong-Password"
$env:ADMIN_NAME="Croc City Administrator"
npm run create-admin
```

The script will:

- create the Firebase Authentication account if it does not exist;
- otherwise update the existing account;
- mark the admin email as verified;
- set the trusted Firebase custom claim `admin=true` and `role=admin`;
- create/update `users/{uid}` with `role: Administrator` and `admin: true`.

## 4. Run the Flutter app

```powershell
cd ..
flutter pub get
flutter run
```

Log in on the normal Login screen using the administrator email and password. The app reads the admin custom claim and opens the Admin Dashboard. Public registration is disabled. Only the administrator can create Player, Player Parent, Coach, Student and Student Parent accounts from the Administrator Dashboard. The administrator then gives each user their username and temporary password.

## 5. Security rules

`firestore.rules` is included as a starting point. Review it against every collection used by the final academy app before deploying it. The Flutter UI is not a security boundary; Firebase Security Rules must enforce admin-only writes.

Deploy only after testing:

```powershell
firebase deploy --only firestore:rules
```

## If the admin cannot log in

1. Confirm the account exists under Firebase Authentication.
2. Confirm the email/password are correct.
3. Confirm the account is enabled.
4. Run the admin tool again to restore the `admin=true` claim and profile.
5. Sign out and sign in again so the client receives a fresh ID token.

The admin tool never stores the password in this project; it reads it from `ADMIN_PASSWORD` at runtime.

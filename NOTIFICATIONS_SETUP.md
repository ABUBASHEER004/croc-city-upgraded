# CROC-CITY FOOTBALL ACADEMY — Notifications

The academy notification system now covers both communication and operational events.

## What is connected

- Firebase Cloud Messaging (FCM) for push delivery.
- Firestore `users/{uid}/notifications` as the notification inbox/history.
- `flutter_local_notifications` for foreground alerts.
- FCM tokens stored in `users/{uid}.fcmTokens`.
- Role-aware recipient resolution on the backend.

### Automatic notification events

| Event | Notification recipients |
|---|---|
| Announcement | Audience/explicit recipients already defined by the announcement |
| Training session created | Players on the training team, their parents, and the assigned coach |
| Training session important update | Players on the team, parents, and coach |
| Fixture created | Players on the fixture team, their parents, and the assigned coach |
| Fixture important update | Players on the team, parents, and coach |
| Assignment published | Linked student accounts and their parents/linked academy contacts |
| Attendance recorded/updated | Affected student, parent, and assigned coach |
| Student result published | Student, parent, coach and teacher linked to the student |
| Player result published | Player account, parent and coach |

The notification inbox stores the event `type` and `entityId`, so the app can distinguish training, fixtures, assignments, attendance, and results.

## 1. Install Flutter packages

From the project root:

```powershell
flutter pub get
```

## 2. Deploy the backend

From the project root:

```powershell
firebase deploy --only functions,firestore:rules
```

The backend functions include:

- `sendAcademyNotificationOnCreate`
- `sendAcademyNotificationOnPublish`
- `sendTrainingNotificationOnCreate`
- `sendTrainingNotificationOnUpdate`
- `sendFixtureNotificationOnCreate`
- `sendFixtureNotificationOnUpdate`
- `sendAssignmentNotificationOnCreate`
- `sendAssignmentNotificationOnPublish`
- `sendAttendanceNotificationOnCreate`
- `sendAttendanceNotificationOnWrite`
- `sendStudentResultNotificationOnPublish`
- `sendPlayerResultNotificationOnPublish`

The functions create the in-app notification record first and then send FCM push notifications to available device tokens.

## 3. Test the complete notification flow

### Training

1. Sign in as a coach/admin.
2. Create a training session for a team.
3. Confirm the team's players receive the notification.
4. Confirm linked parents receive it.
5. Change the training time/location/status and confirm an update notification is generated.

### Fixtures

1. Create a fixture for a team.
2. Confirm the players, parents and coach receive it.
3. Change the fixture date, venue, status or score and confirm an update notification.

### Assignments

1. Sign in as a teacher.
2. Publish an assignment to linked students.
3. Confirm each selected student receives a notification.
4. Confirm the linked student's parent also receives the notification when a student record has a parent account.

### Attendance

1. Take attendance for a student.
2. Confirm the student/parent receives the attendance notification.
3. Change the attendance status and confirm the updated status creates a new notification.

### Results

1. Publish a student academic result.
2. Confirm the student and parent receive a result notification.
3. Publish a player performance result.
4. Confirm the player, parent and coach receive it.

### Push + inbox

For each event, verify:

- operating-system push notification when the app is in the background/closed;
- foreground notification when the app is open;
- saved notification in the in-app Notifications screen;
- unread badge increments;
- marking the notification as read works;
- deleting a notification works.

## 4. Important role behavior

The backend respects the existing academy role model:

- Administrator/Admin
- Staff
- Coach
- Teacher
- Player
- Student
- Player Parent/Parent
- Student Parent

Direct recipient IDs are preferred where the event already knows the affected users. For team-based football events, player records are used to resolve the player's account, parent account and coach account.

## 5. Android

Android 13+ requires notification permission. The Flutter app requests it and the manifest contains:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

The notification channel is:

```text
academy_updates
```

## 6. iOS

For iOS push delivery, make sure the iOS Runner target has:

- Push Notifications capability.
- Background Modes → Remote notifications.
- An APNs key/certificate configured for the Firebase project.

The Firebase iOS configuration must also be present in the Runner target.

## 7. Registration error

The managed-user Cloud Function accepts both:

```text
Admin
Administrator
```

and stores the canonical role as:

```text
Administrator
```

It also reports the exact missing registration field instead of returning a generic validation message.

The admin user-creation function must be redeployed after this change.

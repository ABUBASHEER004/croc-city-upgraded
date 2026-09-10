# Code.io upload checklist

This archive is packaged with the Flutter project root at the ZIP root.

The first-level files must include:

- `pubspec.yaml`
- `lib/`
- `web/`
- `android/`
- `ios/`
- `firebase.json`

Do **not** add another `croc_city_football_academy/` folder around these files when uploading to Code.io.

The dependency-install failure:

`Failed to install dependencies for pubspec file in /Users/builder/clone. Directory was not found`

is consistent with the build service receiving an archive whose Flutter project is nested below the directory it treats as the project root. This package avoids that nesting.

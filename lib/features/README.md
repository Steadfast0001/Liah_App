# Feature Folders

Each folder under `lib/features/` contains one part of the school system, such
as students, admissions, or attendance. Features use the same five folders:

- `models/`: Dart classes that describe the data used by the feature.
- `services/`: Code that reads or writes data, usually through Supabase. Existing
  repository interfaces and implementations live together here.
- `providers/`: Riverpod providers that make feature data and actions available
  to the UI.
- `screens/`: Full pages shown in the app.
- `widgets/`: Smaller UI pieces used by one or more screens in the feature.

Typical flow:

`screen -> provider -> service -> Supabase`

The service returns model objects; the provider exposes them to the screen.
Start with the screen, follow its provider to see where data comes from, then
look at the service for the database request.
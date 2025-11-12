# To-Do List: Firestore -> Realtime Database Migration

## Summary
The To-Do List storage layer has been migrated from Cloud Firestore to Firebase Realtime Database while preserving existing functionality and improving real-time synchronization.

## Data Model
- Path: `users/{uid}/todo_lists/{listId}`
- Fields per list: `name` (string), `date` (string), `items` (array of maps), `createdAt` (ISO string), `timestamp` (server timestamp)
- Items retain the same schema: `id`, `title`, `isCompleted`, `createdAt`, `listNumber`

## Real-Time Sync
- A subscription listens at `users/{uid}/todo_lists` and updates the in-memory cache.
- UI binds via a `ValueListenableBuilder` to `TodoStorage.todoListsListenable` for immediate updates.

## Backward Compatibility
- On initial load, if RTDB has no lists, existing Firestore lists are read and migrated to RTDB with the same IDs.
- Firestore remains available for Diary Notes; To-Do writes now target RTDB.

## Security Rules
Deploy `database.rules.json` to Realtime Database to restrict access to authenticated users and basic field validation.

## Error Handling
- Realtime-specific errors are mapped to user-friendly messages: permission denied, network/disconnected, timeout.

## Testing
- Unit tests use a fake in-memory backend injected via `TodoStorage.debugSetBackend` to cover CRUD and realtime behavior.

## Behavioral Differences
- Ordering uses `timestamp` field; server timestamp semantics differ between Firestore and RTDB but user-visible behavior remains consistent.
- RTDB stores arrays as indexed objects; validation rules reflect object presence rather than strict list typing.

## Rollback Procedure
1. Disable RTDB writes by swapping backend to Firestore in `TodoStorage` (temporary hotfix: implement a Firestore backend and set via `debugSetBackend`).
2. Point UI back to Firestore loading by replacing calls in `TodoStorage` with Firestore methods.
3. Remove RTDB subscription (`startRealtimeSync` / `stopRealtimeSync`).
4. Verify CRUD operations using existing Firestore data.

## Deployment Notes
- Ensure Realtime Database is enabled in the Firebase project.
- Provide `databaseURL` in platform configs where required.
- Run `flutter pub get`, then `flutter analyze` and `flutter test`.
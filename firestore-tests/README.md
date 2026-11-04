# Firestore rules tests

Cross-user write tests for `firestore.rules`, written for the Firebase emulator. They never touch a deployed project.

```bash
npm --prefix firestore-tests install
npx firebase emulators:exec --only firestore "npm --prefix firestore-tests test"
```

Needs the Firebase CLI (`npm install -g firebase-tools`) and a Java runtime. On 4 November 2026 the CLI was not installed on the development Mac, so these tests were written but not yet run; see the agent log for that date.

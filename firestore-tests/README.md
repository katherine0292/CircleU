# Firestore rules tests

Cross-user write tests for `firestore.rules`, written for the Firebase emulator. They never touch a deployed project.

```bash
npm --prefix firestore-tests install
npx firebase emulators:exec --only firestore "npm --prefix firestore-tests test"
```

Needs the Firebase CLI (`npm install -g firebase-tools`) and a Java runtime (`brew install openjdk`, then put `$(brew --prefix openjdk)/bin` on PATH). Both were installed on the development Mac on 5 November 2026 and the 11 tests pass there.

The emulator's `firestore-debug.log` shows an "evaluation error" line for every denied write. That is how the emulator reports its first evaluation pass, made before it loads the document, where every `resource` expression is undefined; it then re-evaluates with the document and the result is a plain `false`. The rules coverage report (`/emulator/v1/projects/<id>:ruleCoverage`) confirms the second pass: no expression records an error. Denials here are real `false` results, not thrown errors.

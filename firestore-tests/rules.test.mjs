// Audit A02/A03 (31 Oct 2026): a signed-in user must not be able to change other members'
// membership, likes, favorites or replies. Runs against the Firestore emulator only; it never
// touches a deployed project. Start it with:
//   npx firebase emulators:exec --only firestore "npm --prefix firestore-tests test"
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc, deleteDoc, arrayUnion } from 'firebase/firestore';

let env;
const ALICE = 'alice', BOB = 'bob', CARA = 'cara';
const circle = { id: 'c1', name: 'Study group', intention: 'Finish the slides', emoji: '📚', creatorName: 'Alice',
  creatorUserID: ALICE, createdAt: new Date(), memberUserIDs: [ALICE, BOB], likedByUserIDs: [ALICE], favoritedByUserIDs: [] };
const post = { id: 'p1', circleID: 'c1', who: 'Alice', authorUserID: ALICE, text: 'Who can take slide 3?',
  createdAt: new Date(), likedBy: [ALICE], replies: [{ id: 'r1', who: 'Bob', authorUserID: BOB, text: 'I can.', createdAt: new Date() }] };

before(async () => {
  env = await initializeTestEnvironment({ projectId: 'circleu-rules-test',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') } });
});
after(async () => { await env.cleanup(); });
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'circles/c1'), circle);
    await setDoc(doc(db, 'circles/c1/posts/p1'), post);
  });
});
const asUser = (uid) => env.authenticatedContext(uid).firestore();

test('a member can join and leave, like and favorite, for themselves', async () => {
  const db = asUser(CARA);
  await assertSucceeds(updateDoc(doc(db, 'circles/c1'), { memberUserIDs: arrayUnion(CARA) }));
  await assertSucceeds(updateDoc(doc(db, 'circles/c1'), { likedByUserIDs: [ALICE, CARA] }));
  await assertSucceeds(updateDoc(doc(db, 'circles/c1'), { memberUserIDs: [ALICE, BOB] }));
});

test('a member in the middle of the list can leave', async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await updateDoc(doc(ctx.firestore(), 'circles/c1'), { memberUserIDs: [ALICE, BOB, CARA] });
  });
  await assertSucceeds(updateDoc(doc(asUser(BOB), 'circles/c1'), { memberUserIDs: [ALICE, CARA] }));
});

test('a circle created without like or favorite arrays can still be joined and liked', async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const { likedByUserIDs, favoritedByUserIDs, ...bare } = circle;
    await setDoc(doc(ctx.firestore(), 'circles/c2'), { ...bare, id: 'c2', memberUserIDs: [ALICE] });
  });
  const db = asUser(CARA);
  await assertSucceeds(updateDoc(doc(db, 'circles/c2'), { memberUserIDs: arrayUnion(CARA) }));
  await assertSucceeds(updateDoc(doc(db, 'circles/c2'), { likedByUserIDs: [CARA] }));
});

test('a non-creator cannot remove another member or change their like', async () => {
  const db = asUser(CARA);
  await assertFails(updateDoc(doc(db, 'circles/c1'), { memberUserIDs: [ALICE] }));
  await assertFails(updateDoc(doc(db, 'circles/c1'), { likedByUserIDs: [] }));
  await assertFails(updateDoc(doc(db, 'circles/c1'), { likedByUserIDs: [ALICE, BOB] }));
});

test('a non-creator cannot change metadata or cover art', async () => {
  const db = asUser(BOB);
  await assertFails(updateDoc(doc(db, 'circles/c1'), { name: 'Renamed' }));
  await assertFails(updateDoc(doc(db, 'circles/c1'), { coverImagesBase64: ['AAAA'] }));
  await assertFails(updateDoc(doc(db, 'circles/c1'), { memberUserIDs: arrayUnion(CARA), name: 'Renamed' }));
});

test('the creator can edit metadata but not hand the circle to someone else', async () => {
  const db = asUser(ALICE);
  await assertSucceeds(updateDoc(doc(db, 'circles/c1'), { name: 'Renamed', coverImagesBase64: ['AAAA'] }));
  await assertFails(updateDoc(doc(db, 'circles/c1'), { creatorUserID: BOB }));
  await assertSucceeds(deleteDoc(doc(db, 'circles/c1')));
});

test('a reader can like a post and append one reply of their own', async () => {
  const db = asUser(CARA);
  await assertSucceeds(updateDoc(doc(db, 'circles/c1/posts/p1'), { likedBy: [ALICE, CARA] }));
  await assertSucceeds(updateDoc(doc(db, 'circles/c1/posts/p1'), { replies: [...post.replies,
    { id: 'r2', who: 'Cara', authorUserID: CARA, text: 'Me too.', createdAt: new Date() }] }));
});

test('a reader cannot remove others\' likes, forge an appended reply, or edit the text', async () => {
  const db = asUser(CARA);
  await assertFails(updateDoc(doc(db, 'circles/c1/posts/p1'), { likedBy: [] }));
  await assertFails(updateDoc(doc(db, 'circles/c1/posts/p1'), { replies: [...post.replies,
    { id: 'r2', who: 'Bob', authorUserID: BOB, text: 'Forged.', createdAt: new Date() }] }));
  await assertFails(updateDoc(doc(db, 'circles/c1/posts/p1'), { text: 'Edited by someone else' }));
  await assertFails(deleteDoc(doc(db, 'circles/c1/posts/p1')));
});

test('a reader can like a reply, and edit or delete their own reply', async () => {
  const db = asUser(BOB);
  const liked = [{ ...post.replies[0], likedBy: [BOB] }];
  await assertSucceeds(updateDoc(doc(db, 'circles/c1/posts/p1'), { replies: liked }));
  await assertSucceeds(updateDoc(doc(db, 'circles/c1/posts/p1'), { replies: [{ ...post.replies[0], text: 'I can, tomorrow.' }] }));
  await assertSucceeds(updateDoc(doc(db, 'circles/c1/posts/p1'), { replies: [] }));
});

test('a reader cannot replace the whole thread in one write', async () => {
  const db = asUser(CARA);
  await assertFails(updateDoc(doc(db, 'circles/c1/posts/p1'), { replies: [...post.replies,
    { id: 'r2', who: 'Cara', authorUserID: CARA, text: 'One', createdAt: new Date() },
    { id: 'r3', who: 'Cara', authorUserID: CARA, text: 'Two', createdAt: new Date() }] }));
});

test('only members can create posts, and only as themselves', async () => {
  await assertFails(setDoc(doc(asUser(CARA), 'circles/c1/posts/p2'), { ...post, id: 'p2', authorUserID: CARA, replies: [], likedBy: [] }));
  await assertFails(setDoc(doc(asUser(BOB), 'circles/c1/posts/p2'), { ...post, id: 'p2', authorUserID: ALICE, replies: [], likedBy: [] }));
  await assertSucceeds(setDoc(doc(asUser(BOB), 'circles/c1/posts/p2'), { ...post, id: 'p2', authorUserID: BOB, who: 'Bob', replies: [], likedBy: [] }));
});

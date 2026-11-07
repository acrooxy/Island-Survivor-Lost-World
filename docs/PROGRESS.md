# Persistent progress — Island Survivor: Lost World

Status: development build with a verified desktop survival foundation; overall game incomplete.

## Implementation plan
1. M1: landscape Godot project, original vector-style island rendering, player movement, touch joystick, camera, beach resources and interaction. Validate import, scripts and runtime.
2. M2: data-driven needs and recipes, transactional inventory, durability, valid building placement, rest, cooking, water, storage, versioned saves and recovery. Test inventory capacity, recipe failure atomicity, survival timing and save round trips.
3. M3: six connected regions, resource regeneration, wildlife states and combat, discoveries, 20 sequential quests across five chapters, escape and continued exploration. Test progression and reachable objectives.
4. M4: consistent art, animation, audio, weather, fog, accessible HUD, onboarding, performance and balance. Review actual rendered gameplay; profile on target hardware.
5. M5: Android export and installation, maintained rewarded-ad plugin and consent, lifecycle tests, release art and current Play policy review. Production ads and publishing require owner approval.

## Environment evidence
2026-11-07: new empty workspace. No Godot, Git, Java or adb found on command path. Android SDK directory exists. Portable engine download permission requested. Node available. No tests run yet.

## Verified progress, 2026-11-07
- Downloaded official Godot 4.7.2 and portable Git. Found Java 25.0.4 in Android Studio and a running Android emulator.
- M1 foundation: actual desktop OpenGL launch, HUD/world/character rendered, E gathered wood, keyboard movement passed automated process-loop test. Fixed starter crabs attacking unprovoked and action button overlap. Local commit 87b506a on milestone/m1-playable.
- M2 systems: 13 survival/inventory checks passed, including failed transactions and save round trip. Structure overlap consumes no materials. Implemented shelter, cooking, fishing, collector, storage and version 1 saves. Completion is partial: wider manual UI and corruption/lifecycle cases remain.
- M3 systems: six region definitions, seeded resource population checked for valid terrain. 26 integration checks passed including story fixture progression through rescue/free roam. Not a full player playthrough; authored world/AI/story depth remains incomplete.
- M4 in progress: original procedural art, icon, ocean/music/effect WAVs and persistent volume control implemented. Actual-render screenshots captured. Audio listening and physical performance tests pending.
- M5 in progress: Windows executable exported. First Android debug APK export succeeded with template SDK defaults after SDK access/configuration fixes. Rebuilding with the new project icon. APK installation/run, AAB and ads still pending at this record.
- User authorised uploading to their existing public repository acrooxy/Island-Survivor-Lost-World. It was empty; initial .gitignore commit created on main, development/first-playable branch created. Upload remains pending until verified below.

## Next actions
1. Finish Android rebuild, install/launch on emulator, inspect manifest and logcat, capture actual Android screen.
2. Re-run tests after final modifications; copy clean evidence logs and commit.
3. Upload complete source/assets/docs to development/first-playable; verify remote tree and open a draft PR.
4. Continue M2–M4 quality gaps listed in KNOWN_ISSUES; integrate and verify native ads/consent only after choosing a compatible plugin.

## Rules for continuation
Resume from this document and test results. Features described in design documents are intentions until verified. Never mark Android, ads, performance or visual QA passed without running the corresponding tests. Never include signing secrets in source.

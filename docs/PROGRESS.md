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
- M2 systems: 15 survival/inventory checks passed, including failed transactions, save round trip, malformed schema rejection and backup recovery. Structure overlap consumes no materials. Implemented shelter, cooking, fishing, collector, storage and version 1 saves. Completion is partial: wider manual UI and interrupted-write/lifecycle cases remain.
- M3 systems: six region definitions, seeded resource population checked for valid terrain. 26 integration checks passed including story fixture progression through rescue/free roam. Not a full player playthrough; authored world/AI/story depth remains incomplete.
- M4 in progress: original procedural art, icon, ocean/music/effect synthesis and persistent volume control implemented. Actual-render screenshots captured. Large WAV renders were replaced by compact original synthesis source after connector review rejected the oversized payload; source and screenshots uploaded successfully. Audio listening and physical performance tests pending. Headless test runs skip playback, avoiding audio-driver shutdown warnings; this is explicitly not an audio test.
- M5 in progress: Windows executable and signed debug APK exported with original icon. Android manifest inspected: min SDK 24, target/compile SDK 36. APK install could not run because no device remained connected. A new isolated emulator failed to start because hardware acceleration was unavailable. No Android install/play result is claimed. AAB and native ads/UMP remain unimplemented.
- User authorised uploading to existing public repository acrooxy/Island-Survivor-Lost-World. Complete current source/assets/docs uploaded on development/first-playable, initial source commit 08e5ac07f1dd7b077c24b0e33492819aa075a848; remote tree inspected and all 31 initial intended files were present. Draft PR: https://github.com/acrooxy/Island-Survivor-Lost-World/pull/1 . Follow-up commits include final test evidence, cleanup and packaged engine licence notices. Branch/PR remain unmerged.

## Next actions
1. Run APK install/launch on a physical device or hardware-accelerated emulator; capture actual Android gameplay and lifecycle evidence.
2. Continue M2–M4 quality gaps listed in KNOWN_ISSUES, especially full unassisted story playthrough, original final art, collision/pathfinding, water purification, base upgrades and farming.
3. Build and validate a Gradle AAB with a compatible JDK and installed SDK platform; no production signing key is configured.
4. Integrate and verify native rewarded ads/UMP using a pinned compatible plugin. No production ad activation or publishing without owner approval.

## Rules for continuation
Resume from this document and test results. Features described in design documents are intentions until verified. Never mark Android, ads, performance or visual QA passed without running the corresponding tests. Never include signing secrets in source.

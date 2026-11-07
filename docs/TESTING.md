# Reproducible testing

Use Godot 4.7.2 stable. Commands below assume `godot` refers to that executable and you are in the project folder. On this host a portable engine lives under the enclosing workspace `work/godot/`. Its `_sc_` marker keeps editor settings local. Set APPDATA to a writable development directory when running in a restricted environment; do not alter the machine-wide setting.

```
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/test_survival.gd
godot --headless --path . --script res://tests/test_game.gd
godot --headless --path . --quit-after 120
godot --path .
```

Unit saves use `unit-test` and progression saves use `integration-test`, isolated from `island` player saves. Test fixtures supply materials and teleport between story landmarks; they do not prove the difficulty, navigation or story pacing of an unassisted playthrough.

## Evidence recorded 2026-11-07
- Engine: 4.7.2.stable.official.ed1daf0bf.
- Headless startup: 120 frames, exit 0, no reported game errors.
- Survival test: 13 checks passed after fixing JSON numeric-type normalisation.
- Integration test: 26 checks passed after correcting input event buffering in the test. Covers resource bounds, input movement, peaceful crab, crafting/placement failure atomicity, fixture progression through all objectives, ending/free roam, respawn and saved structures.
- Desktop visual inspection: actual OpenGL renderer on NVIDIA GeForce GTX 1650; observed HUD, island, character, wildlife, touch controls and E gathering (+2 wood). Found overlapping buttons and aggressive beach crabs; implementation corrected and integration regression added. Recheck the final built UI after changes.

Logs are supplied alongside the project. Record new results rather than assuming previous tests cover later changes.

## Required manual checks
Fresh save: gather, craft axe, place shelter, eat coconut, survive first night, respawn, craft all structures, store/take stacks, cook/fish/farm/collect water, complete all 20 quests without fixtures, use raft, continue free roam, quit/reload.

Touch: drag joystick while pressing attack, interrupted finger release, system back, home/resume, incoming call, screen rotation, cutouts, 16:9/20:9/tablet dimensions. Verify menus stop all survival timers and reset joystick. Kill app during save and verify backup recovery. Fill storage, deny writes, corrupt both saves and verify graceful recovery.

Android: verify installation, arm64 and x86_64 support, minimum/target SDK in built manifest, app signing, offline launch, 30–60 FPS on a physical mid-range phone. Profile draw cost and allocations for at least 20 minutes. No physical-device performance result is currently claimed.

Ads once integrated: test IDs only; consent required/denied/error; no fill, no network, cancelled video, verified reward, duplicate callback, delayed callback after death, daily quotas across restarts, midnight/timezone/clock changes. Verify one revive per death and no reward on close alone.

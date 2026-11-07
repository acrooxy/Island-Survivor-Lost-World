# Known issues and missing release work

This is a development build. The definition of done has not been met.

- No integrated AdMob plugin, UMP consent or tested rewarded callbacks. Optional ad rewards are unavailable. No production advertisements are active.
- No full manual unassisted story playthrough or long-run survival balance certification.
- Android debug APK exports and verifies its signature, but install/play remain unverified: the available emulator stopped and the replacement could not access hardware acceleration. No physical target-device 30–60 FPS profiling, battery, thermal, multi-touch or Android lifecycle certification yet.
- Original procedural cartoon art is early art direction, not final release asset quality. Buildings share simplified shapes; animals need differentiated animation and silhouettes.
- Original ocean/music/action audio, persistent volume setting and vector app icon are implemented; listening review, final mastering, feature graphic and final Android store screenshots remain pending.
- The world has circular colour fields and paths. Terrain lacks caves and solid resource collisions. Creature steering has no obstacle pathfinding. Trees can obscure the player; resource labels/icons are limited.
- Buildings include all requested types but upgrades, defensive behaviour, farming and storage are basic. No dedicated water purification crafting chain; collector water is assumed safe.
- Fishing is an immediate coast interaction; no cast timing or fishing minigame.
- Weather differences are visual and lack a distinct storm simulation.
- Quest objectives use inventory counts, so spending materials before a relevant objective can require gathering them again. Story content is short; the ruins seal is one simple knowledge/daylight puzzle.
- Tool duplicates share durability per item type. Wildlife positions and damage currently reset on reload; resource timers and structures persist.
- Work energy cost differs from specified timed active work model. No adjustable difficulty.
- UI needs device safe areas, controller focus testing, dynamic recipe formatting and scalable localisation support. Quick items are fixed food/herb shortcuts.
- Save validation now checks nested data types and backup recovery is tested. Further corruption, interrupted-write and low-storage testing and migration support beyond version 1 remain.
- Source/assets/docs uploaded to the owner-supplied public acrooxy/Island-Survivor-Lost-World repository on `development/first-playable`, draft PR #1. Generated APK/EXE stay in local outputs, outside Git source history.
- No release signing identity or Play Console account configured. Do not upload development builds to production.

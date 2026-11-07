# Asset provenance

All current game visuals are original geometric drawing instructions in `scripts/game.gd`, created for this project. No copied game sprites, characters or third-party art packs are included. They can be modified and used commercially as project assets. Their visual quality is development quality and must be reviewed before release.

Godot engine/export templates: Godot Engine contributors, MIT licence. Official source and licence: https://github.com/godotengine/godot/blob/master/LICENSE.txt . Engine and editor are downloaded to the workspace tools directory, not included in source Git history.

UI currently uses Godot's default theme and bundled font. Before distribution include the complete engine third-party notices from the exact Godot release (including font licences). https://godotengine.org/license/ . Do not assume this short ledger replaces the required attribution notices.

The palm/raft icon in `assets/icon.svg` is original project vector artwork. Ocean ambience, pentatonic island music and action cue are original mathematical synthesis in `scripts/audio_factory.gd`, generating looped PCM streams at startup. No external recordings or sampled music were used. Commercial project use is permitted. Audio quality and loop joins still require listening review. Earlier WAV renders have been replaced by compact source synthesis to reduce binary size and distribution overhead.

Exact-release Godot MIT licence and third-party copyright notices are included in `docs/third-party/` and packaged from `assets/legal/`, readable through Pause → Credits & engine licences. No advertisement plugin is currently included. Record any later additions with author, source URL, exact licence, version and modification history before release.

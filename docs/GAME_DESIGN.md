# Game design and technical decisions

## Pillars
Readable tropical exploration, short purposeful gathering trips, forgiving recovery, and a mystery that gives crafting a destination. Intended play session: 5–15 minutes. First chapter teaches wood, stone, tools and shelter. Each chapter supplies a practical reason to enter the next region.

## World
2048 × 2048 units, circular coast around (1024,1024). Six authored region centres connected through a central path network. Resource positions use seed 84719 with bounds validation. Resources regenerate after 150 seconds. Fog covers undiscovered regions. Beach has peaceful crabs; jungle has boars; swamp has snakes; mountain predators emerge at night. Current terrain geometry and region fog are intentionally simple development art and need authored shoreline and more distinct landmarks.

## Loop
Gather → eat/drink → craft tools → place base → discover regions → recover expedition journals and key → retrieve cove components → build workbench/radio/raft → interact with raft → rescue ending → continued exploration.

Inventory starts with 20 slots, stacks of 50. Five food/herb shortcuts. Resource deduction validates all ingredients before changing inventory. Structure ingredients are charged only at valid placement, avoiding material loss when a preview is blocked. Radio and cabin require a workbench. Early recipes match the owner specification. Tools start at 60 uses. Buildings persist in version 1 saves, with a previous-file recovery copy.

## Survival
100 health, 80 hunger, 80 thirst, 100 energy. Hunger loses 1/20 s; thirst 1/12 s; movement energy 1/15 s. Work currently costs 0.5 per gathering action, an explicit deviation needing balance revision. Zero hunger/thirst drains 0.75 health/s. Energy exhaustion slows movement to 65%; it never immobilises the player. Death restores needs and grants 25 seconds of wildlife protection. Basic resources lose 20%; story items and tools stay.

12 minute day: eight minutes daylight, four minutes night. Sunny/rain/storm alternate every three minutes. Current storm has rain visuals; lightning, storm sound and differentiated mechanical effects are pending.

## Chapters
1. The Awakening: gather wood, stone, axe, shelter.
2. Into the Jungle: discovery, fibre, rope, collector.
3. The Signal: mountains, pickaxe, iron, expedition journal.
4. The Lost Expedition: swamp, herbs, ruins, daylight seal key.
5. Escape or Stay: cove, components, radio, raft rescue.

The journal describes a transmitter concealed in the cove. The ancient seal requires the journal and daylight. The key opens the expedition cache. Quest completion restores 10 health. Current quests check present inventory rather than historical acquisition; a later production quest system should record durable objective events.

## Architecture decisions
Compatibility renderer for broad mobile support, no external gameplay dependencies, CanvasLayer UI scaled from 1280×720, seeded placement for reproducibility, original code-drawn art. All gameplay is local. No fake rewarded ad flow. Advertising remains unavailable until a real native plugin and UMP consent are installed and verified. Android keystores remain outside source.

## Targeted improvements
Extract input/UI/world/combat/quests into independent components; data-drive animal stats and objectives; add terrain collision, pathfinding and occlusion-aware draw order; meaningful cabin upgrades; deep farming and water purification; richer story dialogue, progress map, animated sprites and final audio. Add proper safe-area handling and customisable quick slots before certification.

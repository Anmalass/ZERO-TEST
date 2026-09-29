# PROJECT ZERO (prototype)
Game platform/launcher in Godot 4.3+ (GDScript). Open `project.godot`, press F5.
Flow: Launcher > Library > Zero Test > PLAY > loading > 3D game > ESC/BACK > launcher.
Controls: WASD/Arrows (PC), left-half touch drag (mobile), ESC = back.

## Structure
- `core/` autoloads: `save.gd` (profile, achievements, graphics), `asset_manager.gd` (manifest, priority queue, threaded loading, retry, tiers), `cache_manager.gd` (size, limit, LRU eviction, clear), `net_session.gd` (multiplayer interface only).
- `launcher/` UI built in code, reads games from manifests. `platform/achievements.json` global achievements.
- `games/<id>/manifest.json` = add a folder to add a game. No launcher code changes.
- `games/zero_test/` playable slice; its manifest lists assets with priority 1/2/3 (player is P1, coins P2, scenery P3 streams in after play starts).

## Notes for other AI/devs
- Streaming is a local prototype. To go CDN: replace `ResourceLoader` in `asset_manager.gd` with HTTP download to `user://`, keep states (queued/loading/ready/failed).
- Predictive streaming: add player velocity -> region priority in `AssetManager` (not implemented).
- Graphics presets only set 3D resolution scale; CUSTOM options are not built yet.
- Android export: add `*.json` to export include filter so manifests are packed.
- Store/Friends tabs are placeholders. Not yet tested inside Godot: run and report errors.

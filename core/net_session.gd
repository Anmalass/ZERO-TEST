class_name NetSession
extends RefCounted
# Interface only. Implement LocalSession (LAN/hotspot) and OnlineSession (matchmaking/dedicated server) later.
func host(_game_id: String) -> void: pass
func join(_address: String) -> void: pass
func leave() -> void: pass
func send(_channel: String, _payload: Dictionary) -> void: pass

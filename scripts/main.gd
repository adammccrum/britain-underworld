extends Control

const PORT := 24567
const MAX_CLIENTS := 16
var selected_role := "police"
var status_label: Label
var players_label: Label
var role_button: Button

func _ready() -> void:
    var layout := VBoxContainer.new()
    layout.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    layout.custom_minimum_size = Vector2(420, 260)
    add_child(layout)

    var heading := Label.new()
    heading.text = "BRITAIN: UNDERWORLD | Prototype 0.1"
    layout.add_child(heading)

    role_button = Button.new()
    role_button.text = "Role: Police (click to switch)"
    role_button.pressed.connect(_toggle_role)
    layout.add_child(role_button)

    var host_button := Button.new()
    host_button.text = "Host local game"
    host_button.pressed.connect(_host)
    layout.add_child(host_button)

    var join_button := Button.new()
    join_button.text = "Join localhost game"
    join_button.pressed.connect(_join)
    layout.add_child(join_button)

    status_label = Label.new()
    status_label.text = "Not connected"
    layout.add_child(status_label)

    players_label = Label.new()
    players_label.text = "Connected peers: 0"
    layout.add_child(players_label)

    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    multiplayer.connected_to_server.connect(_on_connected)
    multiplayer.connection_failed.connect(_on_failed)
    multiplayer.server_disconnected.connect(_on_disconnected)

func _toggle_role() -> void:
    selected_role = "criminal" if selected_role == "police" else "police"
    role_button.text = "Role: %s (click to switch)" % selected_role.capitalize()

func _host() -> void:
    var peer := ENetMultiplayerPeer.new()
    var error := peer.create_server(PORT, MAX_CLIENTS)
    if error != OK:
        status_label.text = "Host error: %s" % error
        return
    multiplayer.multiplayer_peer = peer
    status_label.text = "Hosting on port %d as %s" % [PORT, selected_role]
    _refresh_players()

func _join() -> void:
    var peer := ENetMultiplayerPeer.new()
    var error := peer.create_client("127.0.0.1", PORT)
    if error != OK:
        status_label.text = "Join error: %s" % error
        return
    multiplayer.multiplayer_peer = peer
    status_label.text = "Connecting to localhost..."
    _refresh_players()

func _on_connected() -> void:
    status_label.text = "Connected as %s" % selected_role
    _refresh_players()

func _on_failed() -> void:
    status_label.text = "Connection failed"
    multiplayer.multiplayer_peer = null
    _refresh_players()

func _on_disconnected() -> void:
    status_label.text = "Server disconnected"
    multiplayer.multiplayer_peer = null
    _refresh_players()

func _on_peer_connected(_id: int) -> void:
    _refresh_players()

func _on_peer_disconnected(_id: int) -> void:
    _refresh_players()

func _refresh_players() -> void:
    if multiplayer.multiplayer_peer == null:
        players_label.text = "Connected peers: 0"
        return
    players_label.text = "Connected peers: %d" % (multiplayer.get_peers().size() + 1)

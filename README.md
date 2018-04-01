# wireguard-formula

Installs WireGuard (usually dkms and utils), and creates interfaces plus peers.

See the full [Salt Formulas installation and usage instructions](http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html).

# Configuration

All configuration is done via pillar data. See `pillar.example` for examples.

# Available states

## `wg.present (name, listen_port, fwmark, private_key, preshared_key)`

Creates a wireguard interface and sets interface-wide parameters.

## `wg.peer_present (name, interface, endpoint, persistent_keepalive, allowed_ips)`

Adds a peer to an interface and sets peer-specific parameters.

## `wg.absent (name)`

Removes a wireguard interface.

## `wg.peer_absent (name, interface)`

Removes a peer from an interface.

# Excerpt of a few available module functions

`salt-call wg.create wgtest`

`salt-call wg.show wgtest`

`salt-call wg.set interface listen_port=1337`

`salt-call wg.delete wgtest`


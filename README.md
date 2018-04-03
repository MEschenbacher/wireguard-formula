# wireguard-formula

Installs WireGuard (usually dkms and utils), and creates interfaces including
peers. Configuration is done via pillar (see below).

# Installation

See the full [Salt Formulas installation and usage instructions](http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html).

# Configuration

All configuration is done via pillar data. See `pillar.example` for examples.
This means in particular, that you do not have to use any of the following
states youself.

# Available states

## `wg.present`

Creates a wireguard interface and sets interface-wide parameters.

## `wg.peer_present`

Adds a peer to an interface and sets peer-specific parameters.

## `wg.absent`

Removes a wireguard interface.

## `wg.peer_absent`

Removes a peer from an interface.

# wireguard-formula

This formula installs the WireGuard utils and manages interfaces (config files) including
peers. Configuration is done via pillar (see `pillar.example`).

**Important**: On every configuration change, this formula restarts the wireguard interface in
order to apply any changes.

# Requirements

 - systemd: This formula makes use of wireguard-shipped systemd service files
 - wireguard kernel module

# Installation

See the full [Salt Formulas installation and usage instructions](http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html).

# Configuration

All configuration is done via pillar data. See `pillar.example` for examples.
This means in particular, that you do not have to use any of the following
states youself.

Some keys can be present in the config file multiple times. To do this, you can
start a list under a key. If the configuration format allows a single comma
separated string for the respective key, they all will appear in the config
file. Also see `pillar.example`.

# Available states

No states are documented, just include the `wireguard` in the `top.sls` file.

```
base:
  'some_minion':
    - wireguard
```

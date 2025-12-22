# wireguard-formula

This formula installs the WireGuard utils and manages interfaces (config files) including
peers. Configuration is done via pillar (see `pillar.example`).

**Important**: On every configuration change, this formula restarts the wireguard interface in
order to apply any changes. `syncconf` is available to use `wg syncconf` on change.

# Requirements

 - systemd: This formula makes use of wireguard-shipped systemd service files
 - wireguard kernel module

# Installation

See the full [Salt Formulas installation and usage instructions](http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html).

# Configuration

All configuration is done via pillar data. See `pillar.example` for examples.

Some configuration keys can be present in the wireguard config file multiple times. To do
this, you can start a list under a key. If the configuration format allows a single comma
separated string for the respective key, they all will appear in the config file.


# Available states

Only the one state is available: just include the `wireguard` in the `top.sls` file.

```
base:
  'some_minion':
    - wireguard
```

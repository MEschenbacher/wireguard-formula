# wireguard-formula

This formula is supposed to install WireGuard (usually dkms and utils), and
create interfaces including peers. Configuration is done via pillar (see below).

**Attention**: WireGuard is not yet included in the linux mainline kernel. Also,
the installation is different on every distribution and sometimes you even have
to include unstable/testing branches. For now, please
[install WireGuard](https://www.wireguard.com/install/) yourself. You can use
this formula afterwards.

**Important**: On every configuration change, this formula restarts the
wireguard interface in order to apply any changes.

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
file.
```
wireguard:
  interfaces:
    wgtest:
      config:
        DNS:
	  - 8.8.8.8
	  - 1.1.1.1
	DNS: 9.9.9.9, 1.0.0.1
	Address: fe80::1, fe80::2
	Address:
	  - fe80::3
	  - fe80::4
```

# Available states

No states. Include `wireguard` in the top.sls file.

```
base:
[... snip ...]
  'some_minion':
    - wireguard
[... snip ...]
```

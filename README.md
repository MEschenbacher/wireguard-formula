# wireguard-formula

This formula is supposed to install WireGuard (usually dkms and utils), and
create interfaces including peers. Configuration is done via pillar (see below).

**Attention**: WireGuard is not yet included in the linux mainline kernel. Also,
the installation is different on every distribution and sometimes you even have
to include unstable/testing branches. For now, please
[install WireGuard](https://www.wireguard.com/install/) yourself. You can use
this formula afterwards.

# Installation

See the full [Salt Formulas installation and usage instructions](http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html).

# Configuration

All configuration is done via pillar data. See `pillar.example` for examples.
This means in particular, that you do not have to use any of the following
states youself.

# Available states

No states. Include `wireguard` in the top.sls file.

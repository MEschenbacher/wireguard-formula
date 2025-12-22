# 2.2.0

# Features

- we now support the `wireguard:lookup:syncconf` bool (default `false`) which, if set, uses
  `wg syncconf` to apply a changed configuration file. This option only syncs the `[Peer]`
  sections.
- you can now specify the wireguard configuration directory via pillar
  `wireguard:lookup:directory` (default `/etc/wireguard`).
- we now support the `wireguard:lookup:clean` bool (default `false`) which, if set, removes
  any interface configurations under `wireguard:lookup:directory`.
- The options in the configuration file are now ordered and are going to produce a change
  (although no code actually changed). We consider this a feature, however, if you do *not*
  want the interface to restart, you can now for this occasion specify `syncconf=true` once
  e.g. `salt-call state.apply pillar='{"wireguard": {"lookup": {"syncconf": true}}}`
- falsy variables in the pillar are now automatically converted to the string `off` in the
  configuration.

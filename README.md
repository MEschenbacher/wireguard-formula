# wireguard-formula

currently with only `_modules` and `_states`.

# Install

Add the path to the wireguard-formula to the master configuration file under option
`file_roots` or as `gitfs_remotes`.

# Use as module

`salt-call wg.create wgtest`
`salt-call wg.show wgtest`
`salt-call wg.set interface listen_port=1337`
`salt-call wg.delete wgtest`

# Use as state

```
wgtest:
  wg.present:
    - listen_port: 1337

1ymBfBty05PNhD/QJKUlu4aL2p4jKSWVVqVQWIQG6wM=:
  wg.peer_present:
    - interface: wgtest
```

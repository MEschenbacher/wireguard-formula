import yaml
import os
from tempfile import mkstemp

__virtualname__ = 'wg'

def __virtual__():
    # do checks for startup
    return __virtualname__

def create(name):
    """
    create a wireguard interface. This will fail if it already exists.
    """
    __salt__['cmd.run']('ip link add %s type wireguard' % (name,))
    return show(name)

def delete(name):
    """
    delete a interface (not neccessarily a wireguard interface). This will fail
    if it does not exist.
    """
    return __salt__['cmd.run']('ip link del %s' % (name,))


def show(name=None, peer=None, hide_keys=True):
    if peer and not name:
        return 'If peer is given, name must also be given'
    if not name:
        return _wg_ifaces(hide_keys=hide_keys)
    elif peer:
        return _wg_ifaces(hide_keys=hide_keys).get(name).get('peers').get(peer)
    else:
        return _wg_ifaces(hide_keys=hide_keys).get(name)

def showconf(name):
    return __salt__['cmd.run']('wg showconf %s' % (name,))

def set(name, listen_port=None, fwmark=None, private_key=None, peer=None,
        preshared_key=None, endpoint=None, persistent_keepalive=None,
        allowed_ips=None, remove=False):
    s = 'wg set %s' % (name,)
    if remove:
        if not peer:
            return 'If remove is given, peer must also be given'
        return __salt__['cmd.run'](
            '%s peer %s remove' % (s, peer)
        )
    if listen_port:
        s = '%s listen-port %s' % (s, listen_port)
    if fwmark:
        s = '%s fwmark %s' % (s, fwmark)
    if private_key:
        fd, filename = mkstemp(text=True)
        with open(filename, 'w') as f:
            f.write(private_key)
        os.close(fd)
        s = '%s private-key %s' % (s, filename)
    if peer:
        s = '%s peer %s' % (s, peer)
    if preshared_key:
        if not peer:
            return 'If preshared_key is given, peer must also be given'
        fd2, filename2 = mkstemp(text=True)
        with open(filename2, 'w') as f:
            f.write(preshared_key)
        os.close(fd2)
        s = '%s preshared-key %s' % (s, filename2)
    if endpoint:
        if not peer:
            return 'If endpoint is given, peer must also be given'
        s = '%s endpoint %s' % (s, endpoint)
    if persistent_keepalive:
        if not peer:
            return 'If persistent_keepalive is given, peer must also be given'
        s = '%s persistent-keepalive %s' % (s, persistent_keepalive)
    if allowed_ips:
        if not peer:
            return 'If allowed_ips is given, peer must also be given'
        s = '%s allowed-ips %s' % (s, allowed_ips)

    r = __salt__['cmd.run'](s)

    if private_key:
        os.unlink(filename)
    if preshared_key:
        os.unlink(filename2)

    return r

def remove_peer(name, peer):
    return __salt__['cmd.run'](
        'wg set %s peer %s remove' % (name, peer)
    )

#  def add_peer(name, public_key, allowed_ips=None):
    #  base = 'wg set %s peer %s' % (name, peer)
#  
    #  return __salt__['cmd.run'](
    #  )

def genkey():
    return __salt__['cmd.run']('wg genkey')

def genpsk():
    return __salt__['cmd.run']('wg genpsk')

def setconf(name, path):
    return __salt__['cmd.run']('wg setconf %s %s' % (name, path))

def addconf(name, path):
    return __salt__['cmd.run']('wg addconf %s %s' % (name, path))

def _wg_ifaces(hide_keys=True):
    """
    Parse output from 'wg show'
    """
    # from https://github.com/saltstack/salt/blob/develop/salt/modules/linux_ip.py
    tmp = dict()
    tmpiface = dict()
    ifaces = dict()
    out = __salt__['cmd.run']('wg',
            env={'WG_HIDE_KEYS': 'always' if hide_keys else 'never'})
    for line in out.splitlines():
        if line.startswith('interface: '):
            k, v = _wg_splitline(line)
            ifaces[v] = dict(peers=dict())
            tmpiface = ifaces[v]
            tmp = tmpiface
        elif line.startswith('peer: '):
            k, v = _wg_splitline(line)
            tmpiface['peers'][v] = dict()
            tmp = tmpiface['peers'][v]
        elif line == '':
            continue
        k, v = _wg_splitline(line)
        if k == 'allowed ips':
            tmp[k] = [ s.strip() for s in v.split(',') ]
        else:
            tmp[k] = v
    return ifaces

def _wg_splitline(line):
    parts = line.split(':', 1)
    return parts[0].strip(), parts[1].strip()

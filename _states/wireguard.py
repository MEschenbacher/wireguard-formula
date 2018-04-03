__virtualname__ = 'wg'

def __virtual__():
    if 'wg.show' in __salt__:
        return __virtualname__
    return False


def present(name, listen_port=None, fwmark=None, private_key=None):
    """
    Make sure a wireguard interface exists.
    """

    ret = dict(name=name, changes=dict(), result=False, comment=None)

    show = __salt__['wg.show'](name, hide_keys=False)
    if not show:
        __salt__['wg.create'](name)
        ret['changes'][name] = 'Interface created.'

    show = __salt__['wg.show'](name, hide_keys=False)

    if int(show.get('listening port', 0)) != int(listen_port):
        __salt__['wg.set'](name, listen_port=listen_port)
        ret['changes']['listening port'] = dict(
                old=show.get('listening port', 0),
                new=listen_port,
        )

    if show.get('fwmark', None) != fwmark:
        __salt__['wg.set'](name, fwmark=fwmark)
        ret['changes']['fwmark'] = dict(
                old=show.get('fwmark', None),
                new=fwmark,
        )

    if show.get('private key') != private_key:
        __salt__['wg.set'](name, private_key=private_key)
        ret['changes']['private key'] = 'private key changed.'

    ret['result'] = True

    return ret


def absent(name):
    """
    Make sure a wireguard interface is absent.
    """

    ret = dict(name=name, changes=dict(), result=False, comment=None)

    interface = __salt__['wg.show'](name)
    if not interface:
        ret['comment'] = 'Interface %s already absent.' % (name,)
        ret['result'] = True
        return ret

    __salt__['wg.delete'](name)
    ret['changes'][name] = dict(old=name, new=None)
    ret['result'] = True
    return ret


def peer_present(name, interface, endpoint=None, persistent_keepalive=None,
                 allowed_ips=None, preshared_key=None):
    ret = dict(name=name, changes=dict(), result=False, comment=None)

    show = __salt__['wg.show'](interface, hide_keys=False)
    if not show:
        ret['comment'] = 'Interface %s does not exist.' % (interface)
        return ret

    show = __salt__['wg.show'](name=interface, peer=name, hide_keys=False)
    if not show:
        __salt__['wg.set'](interface, peer=name, endpoint=endpoint,
                persistent_keepalive=persistent_keepalive,
                allowed_ips=','.join(allowed_ips), preshared_key=preshared_key)
        ret['changes'][name] = 'Peer created.'
        ret['result'] = True
        return ret

    if show.get('endpoint') and endpoint and show.get('endpoint') != endpoint:
        __salt__['wg.set'](interface, peer=name, endpoint=endpoint)
        ret['changes']['endpoint'] = dict(
                old=show.get('endpoint'), new=endpoint)

    if persistent_keepalive and show.get('persistent keepalive', '').startswith('every %s second' % (persistent_keepalive,)):
        __salt__['wg.set'](interface, peer=name,
                persistent_keepalive=persistent_keepalive)
        ret['changes']['persistent keepalive'] = 'persistent keepalive changed.'
    elif not persistent_keepalive and show.get('persistent keepalive'):
        __salt__['wg.set'](interface, peer=name, persistent_keepalive=0)
        ret['changes']['persistent keepalive'] = 'persistent keepalive removed.'
    if sorted(show.get('allowed ips')) != sorted(allowed_ips):
        __salt__['wg.set'](interface, peer=name, allowed_ips=','.join(allowed_ips))
        ret['changes']['allowed ips'] = dict(new=allowed_ips, old=show.get('allowed ips'))
    print(show.get('preshared key'), preshared_key)
    if preshared_key and show.get('preshared key') != preshared_key:
        __salt__['wg.set'](interface, peer=name, preshared_key=preshared_key)
        ret['changes']['preshared key'] = 'preshared key changed.'
    elif show.get('preshared key') and not preshared_key:
        __salt__['wg.set'](interface, peer=name, preshared_key='')
        ret['changes']['preshared key'] = 'preshared key deleted.'



    ret['result'] = True

    return ret


def peer_absent(name, interface):

    ret = dict(name=name, changes=dict(), result=False, comment=None)

    show = __salt__['wg.show'](interface)
    if not show:
        ret['comment'] = 'Interface %s does not exist.' % (interface)
        return ret

    show = __salt__['wg.show'](name=interface, peer=name)
    if not show:
        ret['comment'] = 'Peer %s already absent.' % (name)
        ret['result'] = True
        return ret

    __salt__['wg.set'](interface, peer=name, remove=True)
    ret['changes'][name] = dict(old=name, new=None)
    ret['result'] = True
    return ret

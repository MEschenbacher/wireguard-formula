{% from "wireguard/map.jinja" import wireguard with context %}

wireguard:
  pkg.installed:
    - name: {{ wireguard.package }}

{% for interface, values in salt['pillar.get']('wireguard:interfaces', {}).items() %}
wireguard_{{ interface }}:
  wg.present:
    - name: {{ interface }}
{% for k, v in values.items() %}
{% if k in ['listen_port', 'fwmark', 'private_key', 'preshared_key'] %}
    - {{k}}: {{v}}
{% endif %}
{% endfor %} {# values.items() #}

{% for peer in values.get('peers', {}) %}
wireguard_{{ interface }}_peer_{{ peer.get('peer') }}:
  wg.peer_present:
    - interface: {{ interface }}
    - name: {{ peer.get('peer') }}
{% if peer.get('endpoint') != None %}
    - endpoint: '{{ peer.get('endpoint') }}'
{% endif %}
{% if peer.get('persistent_keepalive') != None %}
    - persistent_keepalive: {{ peer.get('persistent_keepalive') }}
{% endif %}
{% if peer.get('allowed_ips') != None %}
    - allowed_ips:
{% for subnet in peer.get('allowed_ips', []) %}
      - {{subnet}}
{% endfor %}
{% endif %}
{% endfor %}

{% endfor %}


{% for interface in salt['pillar.get']('wireguard:set_forward_interfaces', []) %}
net.ipv4.conf.{{interface}}.forwarding:
  sysctl.present:
    - value: 1
net.ipv6.conf.{{interface}}.forwarding:
  sysctl.present:
    - value: 1
{% endfor %}

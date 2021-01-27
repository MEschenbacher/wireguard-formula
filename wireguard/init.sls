{% from "wireguard/map.jinja" import wireguard with context %}

wireguard_software:
  pkg.installed:
    - pkgs:
{%- for pkg in wireguard.packages %}
      - {{ pkg }}
{%- endfor %}
{%- if wireguard.get('repository', False) %}
    - require:
      - pkgrepo: wireguard_repo

wireguard_repo:
  pkgrepo.managed:
{%- for k,v in wireguard.repository.items() %}
    - {{ k }}: {{ v }}
{%- endfor %}
{%- endif %}

{%- for interface_name, interface_dict in salt['pillar.get']('wireguard:interfaces', {}).items() %}

  {% if interface_dict.get('delete', False) %}
stop and disable wg-quick@{{interface_name}}:
  service.dead:
    - name: wg-quick@{{interface_name}}
    - enable: False
remove wireguard_interface_{{interface_name}}:
  file.absent:
    - name: /etc/wireguard/{{interface_name}}.conf
  {% else %}
    {% if not interface_dict.get('enable', True) %}
stop and disable wg-quick@{{interface_name}}:
  service.dead:
    - name: wg-quick@{{interface_name}}
    - enable: False
    {% else %}
restart wg-quick@{{interface_name}}:
  service.running:
    - name: wg-quick@{{interface_name}}
    - enable: True
    - watch:
      - file: wireguard_interface_{{interface_name}}_config
    - require:
      - pkg: wireguard_software
    {% endif %}

    {% if interface_dict.get('raw_config') %}
wireguard_interface_{{interface_name}}_config:
  file.managed:
    - name: /etc/wireguard/{{interface_name}}.conf
    - makedirs: True
    - contents_pillar: wireguard:interfaces:{{interface_name}}:raw_config
    - mode: 600
    {% else %}
{% if salt['pillar.get']('wireguard:interfaces:'~interface_name~':config:PrivateKey') == '' %}
wireguard_{{interface_name}}_privatekey_missing:
  test.fail_without_changes:
    - name: "no wireguard private key for interface {{interface_name}} in pillars"
    - failhard: True
{% endif %}
wireguard_interface_{{interface_name}}_config:
  file.managed:
    - name: /etc/wireguard/{{interface_name}}.conf
    - makedirs: True
    - source: salt://wireguard/files/wg.conf
    - template: jinja
    - context:
      interface: {{interface_dict.get('config', {})}}
      peers: {{interface_dict.get('peers', [])}}
    - mode: 600
    {% endif %}

  {% endif %}

{%- endfor %}

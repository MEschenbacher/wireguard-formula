{% from "wireguard/map.jinja" import wireguard with context %}
{%- set directory = wireguard.directory ~ '/' %}
{%- set interfaces = salt['pillar.get']('wireguard:interfaces', {}) %}

{%- macro destroy_interface(interface_name) %}
stop and disable wg-quick@{{interface_name}}:
  service.dead:
    - name: wg-quick@{{interface_name}}
    - enable: False
remove wireguard_interface_{{interface_name}}:
  file.absent:
    - name: {{directory}}{{interface_name}}.conf
{%- endmacro %}

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

{%- for interface_name, interface_dict in interfaces.items() %}

  {% if interface_dict.get('delete', False) %}
{{ destroy_interface(interface_name) }}
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
    - reload: {{ wireguard.syncconf }}
    - watch:
      - file: wireguard_interface_{{interface_name}}_config
    - require:
      - pkg: wireguard_software
    {% endif %}

    {% if interface_dict.get('raw_config') %}
wireguard_interface_{{interface_name}}_config:
  file.managed:
    - name: {{directory}}{{interface_name}}.conf
    - makedirs: True
    - contents_pillar: wireguard:interfaces:{{interface_name}}:raw_config
    - mode: 600
    {% else %}
{% if (interface_dict.get('enable', True) and not interface_dict.get('delete', False)) and (not interface_dict.get('config', {}).get('PrivateKey') and not interface_dict.get('raw_config')) %}
wireguard_{{interface_name}}_privatekey_missing:
  test.fail_without_changes:
    - name: "no wireguard private key for interface {{interface_name}} in pillars"
    - failhard: True
{% endif %}
wireguard_interface_{{interface_name}}_config:
  file.managed:
    - name: {{directory}}{{interface_name}}.conf
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

{%- if wireguard.clean is sameas true %}
  {%- for file in salt['file.find'](directory, maxdepth=1, mindepth=1, name='*.conf', print='name', type='f') %}
    {%- set interface_name = file[:-5] %}
    {%- if interface_name not in interfaces %}
{{ destroy_interface(interface_name) }}
    {%- endif %}
  {%- endfor %}
{%- endif %}

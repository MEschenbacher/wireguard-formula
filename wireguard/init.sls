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
    {% endif %}

    {% if interface_dict.get('raw_config') %}
wireguard_interface_{{interface_name}}_config:
  file.managed:
    - name: /etc/wireguard/{{interface_name}}.conf
    - makedirs: True
    - contents_pillar: wireguard:interfaces:{{interface_name}}:raw_config
    - mode: 600
    {% else %}
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

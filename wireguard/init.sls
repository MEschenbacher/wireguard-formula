{%- for interface in salt['pillar.get']('wireguard', {}).keys() %}

{% if salt['pillar.get']('wireguard:' ~ interface ~ ':delete', False) %}
stop and disable wg-quick@{{interface}}:
  service.dead:
    - name: wg-quick@{{interface}}
    - enable: False
remove wireguard_interface_{{interface}}:
  file.absent:
    - name: /etc/wireguard/{{interface}}.conf
{% elif not salt['pillar.get']('wireguard:' ~ interface ~ ':enable', True) %}
stop and disable wg-quick@{{interface}}:
  service.dead:
    - name: wg-quick@{{interface}}
    - enable: False
{% else %}

{% if salt['pillar.get']('wireguard:' ~ interface ~ ':config') %}
wireguard_interface_{{interface}}_config:
  file.managed:
    - name: /etc/wireguard/{{interface}}.conf
    - contents_pillar: wireguard:{{interface}}:config
    - mode: 600
{% else %}
wireguard_interface_{{interface}}_config:
  file.managed:
    - name: /etc/wireguard/{{interface}}.conf
    - source: salt://wireguard/files/wg.conf
    - template: jinja
    - context:
      interface: {{interface}}
    - mode: 600
{% endif %}

restart wg-quick@{{interface}}:
  service.running:
    - name: wg-quick@{{interface}}
    - enable: True
    - watch:
      - file: wireguard_interface_{{interface}}_config
{% endif %}

{%- endfor %}

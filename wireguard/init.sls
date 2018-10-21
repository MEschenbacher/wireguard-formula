{%- for interface in salt['pillar.get']('wireguard', {}).keys() %}

{% if salt['pillar.get']('wireguard:' ~ interface ~ ':enable', True) %}
wireguard_interface_{{interface}}:
  file.managed:
    - name: /etc/wireguard/{{interface}}.conf
    - contents_pillar: wireguard:{{interface}}:config
    - mode: 640

restart wg-quick@{{interface}}:
  service.running:
    - name: wg-quick@{{interface}}
    - enable: True
    - watch:
      - file: wireguard_interface_{{interface}}
{% else %}
stop and disable wg-quick@{{interface}}:
  service.dead:
    - name: wg-quick@{{interface}}
    - enable: False
{% endif %}

{%- endfor %}

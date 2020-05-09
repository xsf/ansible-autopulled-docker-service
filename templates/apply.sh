#!/bin/bash
# Script to configure container {{ item.name }}
set -euo pipefail
IFS=$'\n\t'
name={{ item.name | quote }}
image_ref={{ item.image | quote }}

full_image_ref="$(docker pull -q "$image_ref")"
{# mind that this is a jinja2 template, hence the weird escaping of {{ and }} #}
latest_id="$(docker inspect --format "{{ '{{' }} .Id {{ '}}' }}" "$full_image_ref")"

# ignore if the container isn’t running yet, the check below will handle 
# that
running_id="$(docker inspect --format "{{ '{{' }} .Image {{ '}}' }}" "$name" || true)"

if [ "$running_id" != "$latest_id" ]; then
  printf 'Applying %q: %q -> %q' "$name" "$running_id" "$latest_id"
  # on failure, give it a few extra moments to clean up
  docker stop "$name" >/dev/null || sleep 5
  # on failure ... hope for the best.
  docker rm -f -v "$name" >/dev/null || true
  docker run -d --name "$name" \
{% for port in item.portmap %}
    -p {{ "%s:%s:%s" | format(port.bind | default('127.0.0.1'), port.host, port.guest) | quote }} \
{% endfor %}
    "$full_image_ref" >/dev/null

  if [ -n "$running_id" ]; then
    # delete old image version
    docker image rm "$running_id" || true
  fi
fi

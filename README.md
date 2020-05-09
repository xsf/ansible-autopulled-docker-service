# autopulled docker service

## Configuration / Variables

See the [defaults file](defaults/main.yml).

## Usage

1. Include the role in your playbook. It must run as root.
2. Configure as described above.
3. Run the playbook.
4. ???
5. PROFIT!

### Managing services after rollout

To force an image update, run:

```console
# systemctl restart xsf-autopulled-docker-service@$name.service
```

where ``$name`` is the `name` value of the container you want to update.
This unit will also have logs concerning the container update process. The
logs can be queried with journalctl as usual:

```console
# journalctl -u xsf-autopulled-docker-service@$name.service
```

### Notes

- This will not clean up old containers which have been removed from the
  configuration.


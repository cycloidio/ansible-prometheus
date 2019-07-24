# Ansible Prometheus role

Initially forked from [mkrakowitzer/ansible-prometheus](https://github.com/mkrakowitzer/ansible-prometheus).

`prometheus` is an [ansible](http://www.ansible.com) role which can install systemd-wide or using docker the following:

 * prometheus
 * alertmanager
 * grafana
 * blackbox_exporter
 * node_exporter
 * mongodb_exporter

## Warnings / Prerequisites

With `install_mode: docker`, which is the default behavior, this role will requires a host with docker-engine installed.

Currently, only `mongodb_exporter` is available with `install_mode: system`.

## Branches

* `master`: current state of the role
* `release-0.1`: state before refactoring with breaking changes introduced with https://github.com/cycloidio/ansible-prometheus/pull/9

## Installation

Using `ansible-galaxy`:

```yaml
# requirements.yml
- src: https://github.com/cycloidio/ansible-prometheus.git
  version: master
  name: cycloid.prometheus
  scm: git
```

Using `git`:

```
$ git clone https://github.com/cycloidio/ansible-prometheus.git
```

## Variables

By default, every `install_{prometheus,alertmanager,grafana,...}` variables are set to `false` which let the this role be used to only install exporters.

See default variables and there values in `defaults/main.yml`.

## Testing (herited from the fork, not working/maintained yet)

### TestKitchen tests

```
$ bundle install
$ KITCHEN\_YAML=".kitchen.vagrant.yml" bundle exec kitchen test
```

### Manual testing
```
$ git clone https://github.com/krakowitzerm/ansible-prometheus.git
$ cd ansible-prometheus
$ ansible-galaxy install --role-file=requirements.yml --roles-path=roles --force
$ vagrant up
$ vagrant ssh
```
Test away

## License
MIT

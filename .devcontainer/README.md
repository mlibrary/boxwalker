# Dev Container Guide

This project includes a dedicated devcontainer setup under `.devcontainer/` for local Rails + Solr development.

## Sync Strategy

- `compose.yml` in the project root is the source of truth for shared services (`app`, `solr`, `zookeeper`).
- `.devcontainer/docker-compose.yml` is an override file that only adjusts the `app` service for editor workflows.
- `.devcontainer/devcontainer.json` loads both compose files in order (`../compose.yml`, then `.devcontainer/docker-compose.yml`).
- Keep runtime version changes in one place by updating `.ruby-version` and `.node-version`, then apply the same values in `.devcontainer/Dockerfile` build args.

## Quick Start

1. Open the project in the devcontainer using `.devcontainer/devcontainer.json`.
2. Wait for `postCreateCommand` to finish (`bundle install && yarn install`).
3. Initialize Solr collections once:

```shell
./solr/dev-init.sh
```

4. Start the app stack from inside the container:

```shell
bin/dev
```

## What Runs In The Dev Container

- `app`: Rails development workspace container.
- `solr`: Solr 9.7 service.
- `zookeeper`: ZooKeeper required by SolrCloud.

`SOLR_URL` is set to:

```text
http://solr:8983/solr/blacklight-collection
```

## Common Tasks

### Rebuild container image after dependency/base changes

```shell
Dev Containers: Rebuild Container
```

### Restart only application process

```shell
bin/dev
```

### Verify Solr is reachable from the app container

```shell
curl -s "http://solr:8983/solr/admin/collections?action=CLUSTERSTATUS"
```

### Run tests

```shell
bundle exec rails test
```

## Troubleshooting

### `Missing RAILS_MASTER_KEY`

The repository has `env.example` with `RAILS_MASTER_KEY=`. If app boot fails due to credentials, set `RAILS_MASTER_KEY` in your environment before running `bin/dev`.

### Solr collection not found

Run initialization again:

```shell
./solr/dev-init.sh
```

### Native gem build failures during `bundle install`

Rebuild the container so package changes in `.devcontainer/Dockerfile` are applied.

### Port conflict on host

The devcontainer forwards ports `3000`, `8983`, and `2181`. If one is in use on your host, stop the conflicting process or adjust forwarded ports in `.devcontainer/devcontainer.json`.


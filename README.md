# boxwalker

## Installation and usage

### Docker

```shell
cp env.example .env
# Then add the RAILS_MASTER_KEY value to .env
docker compose build
docker compose up
/bin/bash ./solr/dev-init.sh
```

### Dev Container (VS Code / JetBrains Gateway)

1. Open the project in a Dev Container using `.devcontainer/devcontainer.json`.
2. Once the container is created, initialize Solr collections once:

```shell
./solr/dev-init.sh
```

3. Start the Rails dev stack from inside the container:

```shell
bin/dev
```

The devcontainer starts `app`, `solr`, and `zookeeper` services and sets `SOLR_URL` to `http://solr:8983/solr/blacklight-collection`.

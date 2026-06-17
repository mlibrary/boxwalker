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
#### Indexing a directory

```shell
# Make sure your directory is in the container, either through including it in the build or copying it in.
docker compose exec app bash
# Inside the container
DIR=<your directory path> REPOSITORY=<repository id> rake arclight:index_dir
```

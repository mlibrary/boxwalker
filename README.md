# boxwalker

## Installation and usage

### Docker

```shell
cp env.example .env
# Then add the RAILS_MASTER_KEY value to .env
docker compose build
docker compose up
/bin/bash ./solr/dev-init.sh # creates the blacklight-collection
```
#### Indexing a directory

```shell
# Inside the container
docker compose exec app bash
DIR=<your directory path> REPOSITORY=<repository id> rake arclight:index_dir

# Outside the container
SOLR_URL=<domain>/solr/blacklight-collection DIR=./<location> REPOSITORY_ID=<repository shortname> rake arclight:index_dir
```
#### Hybrid development
Use hybrid for quick rebuilds of Rails (outside a container) without repeatedly spinning up Solr/Zookeeper for each reset.
```shell
docker compose up solr 
/bin/bash ./solr/dev-init.sh 
SOLR_URL=http://localhost:8983/solr/blacklight-collection bin/dev # recompiles Rails and connects it to Solr in container
```
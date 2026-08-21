# boxwalker

## Installation and usage

### Docker
#### Services shell
```shell
cp env.example .env
# Then add the RAILS_MASTER_KEY value to .env
docker compose --profile app build
docker compose --profile app up
```
#### Command shell
```shell
# Create the blacklight-collection
/bin/bash ./solr/dev-init.sh 
```
#### Indexing a directory
```shell
# Inside the container
docker compose exec app bash
DIR=<your directory path> REPOSITORY=<repository id> rake um_arclight:index_dir

# Outside the container
SOLR_URL=http://localhost:8983/solr/blacklight-collection DIR=./<location> REPOSITORY_ID=<repository shortname> rake um_arclight:index_dir
```
### Docker Hybrid development
Use hybrid for quick rebuilds of Rails (outside a container) without repeatedly spinning up Solr/Zookeeper for each reset.
##### Services shell

```shell
docker compose build
docker compose up 
```
##### Command shell

```shell
# Create the blacklight-collection
/bin/bash ./solr/dev-init.sh 
# Recompiles Rails and connects it to Solr container
SOLR_URL=http://localhost:8983/solr/blacklight-collection bin/dev
```
### Troubleshooting
If you encounter this indexing error post-Boxrunner merge
```
. . . .rake aborted!
Bundler::GemRequireError: There was an error while trying to load the gem 'ruby-vips'. (Bundler::GemRequireError)
Gem Load Error is: Could not open library 'vips.42': dlopen(vips.42, 0x0005): tried: 'vips.42' (no such file), '/System/Volumes/Preboot/Cryptexes/OSvips.42' (no such file), '/usr/lib/vips.42' (no such file, not in dyld cache), 'vips.42' (no such file), '/usr/local/lib/vips.42' (no such file), '/usr/lib/vips.42' (no such file, not in dyld cache).
```
I solved it by installing `vips` using `brew install vips`.    
Then run `bundle install`

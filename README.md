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
#### Start ingest pipeline
```shell
# Add your data under /data/ead/{repo_slug}
mkdir -p ./data/ead
cp -r ./sample-ead/scrc ./data/ead/

# Inside the container
docker compose exec app bash
rake arclight:ingest_everything

```

### Docker Hybrid development
Use hybrid for quick rebuilds of Rails (outside a container) without repeatedly spinning up Solr/Zookeeper for each reset.
##### Services shell

```shell
# Build resque-web and resque images  
docker compose build
# Start zookeeper, solr, postgres, redis, resque and resque-web containers
docker compose up
```
##### Rails shell

```shell
# Create the blacklight-collection
/bin/bash ./solr/dev-init.sh
# Bundle install the gems outside of the container
bundle install
# You may also need to install vips: https://formulae.brew.sh/formula/vips.

# NOTE: The migration and database preparation command here is run by the migrate service
# (see Notes - Database and Migration).
# bin/rails db:prepare 
# Development Rails server using Solr container
SOLR_URL=http://localhost:8983/solr/blacklight-collection bin/dev
```

##### Command shell
```shell
# Rake task to start ingest pipeline
rsync -av --progress sample-ead/ data/ead/
SOLR_URL=http://localhost:8983/solr/blacklight-collection \
  FINDING_AID_DATA=./data bin/rails \
  arclight:ingest_everything
```

##### Browser Resque Web
Open http://localhost:5678 in your browser

## Notes

### Database and Migration

The application is now setup to use a single PostgreSQL database (shared by the `app` and `resque` services)
in both all-Docker and hybrid usages. We use a service called migrate to run `db:prepare`
before both `app` and `resque` run, which helps us avoid race conditions during schema set up.
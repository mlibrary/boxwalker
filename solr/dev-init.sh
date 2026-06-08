#!/bin/bash

docker compose exec solr solr create -c blacklight-core -d /opt/solr/conf

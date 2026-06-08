#!/bin/bash

docker compose exec solr solr create -c blacklight-collection -d /opt/solr/conf

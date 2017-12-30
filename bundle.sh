#!/bin/bash
# Bundles the production containers up into a zip file.

# Build the prod containers
docker-compose -f docker-compose.yml build

# Create container archives
docker save houselights_frontend_prod > houselights_frontend.tar
docker save houselights_backend_prod > houselights_backend.tar

# Zips containers up with compose file
zip houselights.zip houselights_frontend.tar houselights_backend.tar docker-compose.yml

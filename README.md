# powerline-infrastructure
Salt states for the Powerline Infrastructure.

We do not use environments. 

# Usage

Highstate the `dev-apiserver` from the salt master: `salt dev-apiser state.apply`

# Infrastructure

Currently used to build the following roles:

- API servers
- legacy API servers

## Legacy Servers

The original API servers (civix-dev, civix-staging and civix-prod) were built using ansible. However, we have moved away from that tooling. For now, legacy API servers are maintained with the powerline-legacy repo. 

# Pillar Data

Pillar data is served by the civix environment grain on each instance. For example, if you are working on vagrant, all pillars are available to you via standard `*.sls` in `pillar/vagrant/*.sls`. However, if you are working on production, certain pillars are only available from s3.

## S3 Pillar Data

TODO: Update regarding s3 apiserver data (symfony parameters). 


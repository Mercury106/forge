## Forge
![Codeship](https://codeship.com/projects/95bb5cc0-6b1f-0134-d5a6-6efe74dd2a57/status?branch=master-stable
)

This application will hopefully serve static HTML faster than anything else.
It should accept a ZIP file, and host it using S3 and Cloudfront and other servers.

### Overview

Each site has many versions.

A version's contents are a zip file of contents

The zip file has a maximum size depending on what the users pays for

These contents are backed up to S3 for repeated parsings

The version's contents are extracted from their archive

The contents are first modified by the server (in version.rb currently)

  • CDN locations are put instead of relative paths
  • perhaps CDN versions of jquery-1.8.7.min.js, etc?
  • pngcrush / jpeg crushing
  • squish javascript files and tags are inserted
  • anything else we can think of that would make them even faster

The contents are then uploaded onto S3

S3 cannot proxy from a domain to serve example.com/1.html
so their HTML is cached locally and served from memcache and varnish

We have cloudfront bandwidth tiers!
We use cloudfront's accounting system (shit though it is) to determine bandwidth in 24 hour increments on cloudfront (and s3 too for all sites) and enable/disable the cloudfront caching for a site. 

We charge users for usage over their capped allowance.

It's a super crazy easy way to get plain old HTML onto S3 and cloudfront super easily.


## Getting Started

`git clone https://github.com/RiotHQ/forge.git`

We use postgreSQL db.

Copy over the example database configuration and modify as necessary.

```
cp config/database.yml.example config/database.yml
```

`bundle install`

`bundle exec rake db:setup db:seed`

`rails s` or use Anvil to run the server locally.

The server runs with some errors due to the ActiveAdmin.


## Tests

There is an adequate, but not extensive test coverage. Key unit tests are in place. There's currently no UI testing in place for the Ember stuff.

To run the test suite:

Minitest (old but core tests): `bin/rake test`

You will get errors relating to S3 tests if you haven't configured a set of credentials. Either persevere or get it setup.

RSPEC (new, and I'd eventually like to move all test to RSPEC): `bin/rake spec`







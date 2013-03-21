ey-cloud-recipes/mongodb::backup
--------

A chef recipe to do very simple backups (all databases that exists in the MongoDB server). Those backups are stored at Amazon S3 that is attached to the Engine Yard instance.

It makes a few assumptions:

  * You will be running MongoDB on a db_master instance.

Using it
--------

  * add the following to main/recipes/default.rb,

``require_recipe "mongodb::backup"``

  * Upload recipes to your environment

``ey recipes upload -e <environment>``

Credits
--------

Based on [MongoDB ey-cloud-recipes](https://github.com/engineyard/ey-cloud-recipes/tree/master/cookbooks/mongodb).

# squash-engine

This is a fork of the [Squash front-end web application (and API)](https://github.com/SquareSquash/web) with the goal of making Squash's models and controllers embeddable in other applications via `Rails::Engine`.

## Objectives

* Namespace appropriate code (for eventual use with `isolate_namespace`)
* Reduce the number of dependencies overall
* Favor officially- or commmunity-supported solutions over custom Gems
* Make Erector optional
* Abstract away authentication and registration (i.e. Devise, etc.)
* MySQL support (eventually)
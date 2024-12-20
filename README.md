# Redmine GTT S.M.A.S.H Plugin

<!-- ![CI #develop](https://github.com/gtt-project/redmine_gtt_smash/workflows/Test%20with%20Redmine/badge.svg) -->

The Geo-Task-Tracker (GTT) S.M.A.S.H plugin adds support for the mobile app [S.M.A.S.H](https://github.com/moovida/smash):

- Authenticate from S.M.A.S.H with a Redmine account
- Upload mobile notes as issues
- Retrieve custom notes configurations
- and more ...

## Requirements

Redmine GTT S.M.A.S.H **requires PostgreSQL/PostGIS** and will not work with
SQLite or MariaDB/MySQL!!!

- Redmine >= 5.0.0
- [redmine_gtt](https://github.com/gtt-project/redmine_gtt/) plugin

## Installation

To install Redmine GTT S.M.A.S.H plugin, download or clone this repository in
your Redmine installation plugins directory!

```sh
cd path/to/plugin/directory
git clone https://github.com/gtt-project/redmine_gtt_smash.git
```

Then run

```sh
bundle install
bundle exec rake redmine:plugins:migrate
```

After restarting Redmine, you should be able to see the Redmine GTT SMASH plugin
in the Plugins page.

More information on installing (and uninstalling) Redmine plugins can be found
in [Redmine Plugins](http://www.redmine.org/wiki/redmine/Plugins) documentation.

## How to use

- Make sure REST web services is enabled: [http://localhost:3000/settings?tab=api](http://localhost:3000/settings?tab=api)
- Enable the plugin in project settings

The Geo-Task-Tracker (GTT) S.M.A.S.H plugin connects the S.M.A.S.H mobile app
with Redmine GTT.
It adds new API endpoints to provide the tracker type configuration as custom notes.

For more information with screenshots see the [Getting Started](doc/getting-started.md)
guide.

### Project level API endpoint

```txt
http://localhost:3000/projects/(project_id)/smash/tags.json
```

### Global level API endpoint**

```txt
http://localhost:3000/smash/tags.json
```

### Default tracker setting API endpoint

```txt
http://localhost:3000/smash/settings.json
```

## Contributing and Support

The GTT Project appreciates any [contributions](https://github.com/gtt-project/.github/blob/main/CONTRIBUTING.md)!
Feel free to contact us for [reporting problems and support](https://github.com/gtt-project/.github/blob/main/CONTRIBUTING.md).

Help us to translate GTT Project using [OSGeo Weblate](https://weblate.osgeo.org/engage/gtt-project/):

[![Translation status](https://weblate.osgeo.org/widgets/gtt-project/-/redmine_gtt_smash/multi-auto.svg)](https://weblate.osgeo.org/engage/gtt-project/)

## Version History

See [all releases](https://github.com/gtt-project/redmine_gtt_smash/releases)
with release notes.

## Authors

- [Ko Nagase](https://github.com/sanak)
- [Daniel Kastl](https://github.com/dkastl)
- [Nisai Nob](https://github.com/nobnisai)
- ... [and others](https://github.com/gtt-project/redmine_gtt_smash/graphs/contributors)

## Credits

This plugin development was funded by [Hyakumori](https://www.hyakumori.com/). 

## LICENSE

This program is free software. See [LICENSE](LICENSE) for more information.

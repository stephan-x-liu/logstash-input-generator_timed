# Timed Interval Generator Plugin

This is a plugin for [Logstash](https://github.com/elasticsearch/logstash).

## Documentation

This plugin generates a set number of points per second for a set number of seconds.

## Developing

### 1. Plugin Developement and Testing

#### Code
- To get started, you'll need JRuby with the Bundler gem installed.

- Install dependencies
```sh
bundle install
```

#### Test

- Update your dependencies

```sh
bundle install
```

- Run tests

```sh
bundle exec rspec
```

### 2. Running your unpublished Plugin in Logstash

#### 2.1 Run in a local Logstash clone 

##### 2.1.1 Version 1.5 and above

- Edit Logstash `Gemfile` and add the local plugin path, for example:
```ruby
gem "logstash-output-generator_timed", :path => "/your/local/logstash-output-generator_timed"
```
- Install plugin
```sh
bin/plugin install --no-verify
```
- Run Logstash with your plugin
```sh
bin/logstash -e 'input { generator_timed {} } output {stdout {} }'
```
At this point any modifications to the plugin code will be applied to this local Logstash setup. After modifying the plugin, simply rerun Logstash.

##### 2.1.1 Version 1.4 and below

- Copy the file generator_timed.rb into /path/to/logstash-1.4.2/lib/logstash/inputs/

- Run Logstash with your plugin
```sh
bin/logstash -e 'input { generator_timed {} } output {stdout {} }'
```

#### 2.2 Run in an installed Logstash

You can use the same **2.1** method to run your plugin in an installed Logstash by editing its `Gemfile` and pointing the `:path` to your local plugin development directory or you can build the gem and install it using:

- Build your plugin gem
```sh
gem build logstash-output-generator_timed.gemspec
```
- Install the plugin from the Logstash home
```sh
bin/plugin install /your/local/plugin/logstash-output-generator_timed.gem
```
- Start Logstash and proceed to test the plugin
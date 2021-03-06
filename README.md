# Specinfra Docker `nsenter` Backend
[![Gem Version](http://img.shields.io/gem/v/specinfra-backend-docker_nsenter.svg?style=flat)](http://badge.fury.io/rb/specinfra-backend-docker_nsenter)
[![Dependency Status](http://img.shields.io/gemnasium/zuazo/specinfra-backend-docker_nsenter.svg?style=flat)](https://gemnasium.com/zuazo/specinfra-backend-docker_nsenter)
[![Code Climate](http://img.shields.io/codeclimate/github/zuazo/specinfra-backend-docker_nsenter.svg?style=flat)](https://codeclimate.com/github/zuazo/specinfra-backend-docker_nsenter)
[![Travis CI](http://img.shields.io/travis/zuazo/specinfra-backend-docker_nsenter.svg?style=flat)](https://travis-ci.org/zuazo/specinfra-backend-docker_nsenter)
[![Coverage Status](http://img.shields.io/coveralls/zuazo/specinfra-backend-docker_nsenter.svg?style=flat)](https://coveralls.io/r/zuazo/specinfra-backend-docker_nsenter?branch=master)
[![Inline docs](http://inch-ci.org/github/zuazo/specinfra-backend-docker_nsenter.svg?branch=master&style=flat)](http://inch-ci.org/github/zuazo/specinfra-backend-docker_nsenter)

[Serverspec](http://serverspec.org/) / [Specinfra](https://github.com/mizzy/specinfra) backend for Docker `nsenter` execution driver.

## Requirements

* Recommended Docker `1.7.0` or higher.
* `sudo` installed (not in the container).
* `nsenter` binary installed.

## Installation

Add this line to your application's Gemfile:

```ruby
# Gemfile

gem 'specinfra-backend-docker_nsenter', '~> 0.1.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install specinfra-backend-docker_nsenter

## Usage

```ruby
require 'serverspec'
require 'specinfra/backend/docker_nsenter'

set :docker_image, ENV['DOCKER_IMAGE_ID']
set :backend, :docker_nsenter

describe 'Dockerfile run' do
  describe service('httpd') do
    it { should be_enabled }
    it { should be_running }
  end
end
```

## Configuration

Uses the following `Specinfra` configuration options:

- `:sudo_options`: Sudo command argument list as string or as array.
- `:sudo_path`: Sudo binary directory.
- `:sudo_password`
- `:disable_sudo`: whether to disable Sudo (enabled by default).

For example:

```ruby
set :sudo_password, 'fBQ6MB5e7mKUt1X7cNAq'
```

## Testing

See [TESTING.md](https://github.com/zuazo/specinfra-backend-docker_nsenter/blob/master/TESTING.md).

## Contributing

Please do not hesitate to [open an issue](https://github.com/zuazo/specinfra-backend-docker_nsenter/issues/new) with any questions or problems.

See [CONTRIBUTING.md](https://github.com/zuazo/specinfra-backend-docker_nsenter/blob/master/CONTRIBUTING.md).

## TODO

See [TODO.md](https://github.com/zuazo/specinfra-backend-docker_nsenter/blob/master/TODO.md).

## Acknowledgements

* Kudos to [Andreas Schmidt](https://github.com/aschmidt75) for [his implementation example](https://gist.github.com/aschmidt75/bb38d971e4f47172e2de).

## License and Author

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | [Xabier de Zuazo](https://github.com/zuazo) (<xabier@zuazo.org>)
| **Copyright:**       | Copyright (c) 2015 Xabier de Zuazo
| **License:**         | Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

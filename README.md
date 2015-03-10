Sinatra factory
===============
Bash script that creates simple [Sinatra](http://sinatrarb.com) application

Usage
-----
`curl -s https://raw.githubusercontent.com/scaint/sinatra-factory/master/factory.sh | bash -s TARGET_DIRECTORY [OPTIONS]`

Options:

* `-m` Use Sinatra git repository as gem source
* `-B` Do not run bundle install

Example:

1. `curl -s https://raw.githubusercontent.com/scaint/sinatra-factory/master/factory.sh | bash -s myapp -m`
2. `cd myapp`
3. `bundle exec rackup`

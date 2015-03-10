#!/bin/bash

if [[ -z "$1" ]]; then
  echo 'Specify target directory'
  echo './factory.sh TARGET_DIR [OPTIONS]'
  echo -e "\t-m\t--master Use Sinatra git repository as gem source"
  echo -e "\t-B\t--skip-bundle Do not run bundle install"
  exit 1
fi

if [[ -d "$1" ]]; then
  echo 'Target directory already exists'
  exit 1
fi

mkdir -p "$1"
cd "$1"

sinatra_master=0
run_bundle_install=1
app_name=$(basename "$1")
template_engine='slim' #TODO
jquery_version='2.1.3'
bootstrap_version='3.3.2'

shift
while [[ $# > 0 ]]; do
  key="$1"
  case $key in
    -m|--master)
      sinatra_master=1
      ;;
    -B|--skip-bundle)
      run_bundle_install=0
      ;;
    *)
      ;;
  esac
  shift
done

# Adds gem to Gemfile
# Usage: add_gem GEM_NAME [OPTIONS]
add_gem() {
  options=${@:2}
  if [[ -n "$options" ]]; then
    options=", $options"
  fi
  echo "gem '$1'$options" >> Gemfile
}

bundle init || exit

sed -i '/^#/d' Gemfile

if [[ $sinatra_master -eq 1 ]]; then
  add_gem 'sinatra' git: \'https://github.com/sinatra/sinatra.git\'
else
  add_gem 'sinatra'
fi
add_gem 'foreman'
add_gem $template_engine

mkdir {public,public/javascripts,public/stylesheets,views}
touch public/javascripts/application.js
touch public/stylesheets/application.css

cat > 'views/layout.slim' <<EOF
doctype html
head
  meta charset="utf-8"
  meta name="viewport" content="width=device-width, initial-scale=1"
  title ${app_name^}
  link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/$bootstrap_version/css/bootstrap.min.css"
  link rel="stylesheet" href="/stylesheets/application.css"
  script src="//ajax.googleapis.com/ajax/libs/jquery/$jquery_version/jquery.min.js"
  script src="//maxcdn.bootstrapcdn.com/bootstrap/$bootstrap_version/js/bootstrap.min.js"
  script src="/javascripts/application.js"
body
  == yield
EOF

cat > 'views/index.slim' <<EOF
h1 Index
p View file: views/index.slim
EOF

cat > 'app.rb' <<EOF
require 'bundler/setup'
require 'sinatra/base'
require '$template_engine'

class App < Sinatra::Base
  get '/' do
    $template_engine :index
  end
end
EOF

cat > 'config.ru' <<'EOF'
require './app'

run App.new
EOF

cat > 'Procfile' <<'EOF'
web: bundle exec rackup config.ru -p $PORT
EOF

git init
curl -s https://raw.githubusercontent.com/github/gitignore/master/Ruby.gitignore > .gitignore

test $run_bundle_install -eq 1 && bundle install

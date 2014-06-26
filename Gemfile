source "http://rubygems.org"

gem 'sinatra'
gem 'data_mapper'
# gem 'dm-postgres-adapter'

group :production do
	gem 'dm-postgres-adapter'
end

group :test do
	gem 'dm-migrations'
	gem 'rack-test'
	gem 'dm-sqlite-adapter'
end


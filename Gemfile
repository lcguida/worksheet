source "http://rubygems.org"

gem 'sinatra'
gem 'data_mapper'
# gem 'dm-postgres-adapter'
gem 'coveralls', require: false

group :production do
	gem 'dm-postgres-adapter'
end

group :development do 
	gem 'dm-mysql-adapter'
end

group :test do
	gem 'dm-migrations'
	gem 'rack-test'
	gem 'dm-sqlite-adapter'
end


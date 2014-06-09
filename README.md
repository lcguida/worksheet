# WorkSheet #

### What it is? ###

A little Sinatra app that centralizes logged time entries from different redmine isntances

### Como usar? ###

1. Clone the project

```
git clone https://github.com/lcguida/worksheet.git
```

2. `bundle isntall`

3. Create a database.yml file with at least one 'default' database (pointing to a existing redmine database):

```ruby
#database.yml

default:
  adapter: "<mysql,postgres,sqlite>"
  host: "<host>"
  port: <port>
  user: "<user>"
  password: "<password>"
  database: "<database>"
  
#Other databases:
another-redmine:
  adapter: "<mysql,postgres,sqlite>"
  host: "<host>"
  port: <port>
  user: "<user>"
  password: "<password>"
  database: "<database>"

```

3. Create a config.yml as following:

```ruby
#config.yml

bind: <server_bind_address>

```

4. Execute: `bundle execu rackup -p <port>`

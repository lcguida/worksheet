# WorkSheet #




### O que é ? ###

Worksheet é uma pequeno servidor Sinatra com o intuito de centralizar as horas logadas em diferentes instâncias de Redmine.

### Como usar? ###

* Baixe o projeto
* Configure os banco de dados (MySQL) no arquivo config.yml
* Modifique o código de acordo com a sua regra de LDAP
* bundle install
* Execute o servidor através do rackup:


```
#!shell

[$] bundle exec rackup -p $porta
```

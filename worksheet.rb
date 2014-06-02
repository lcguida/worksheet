require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'net/ldap'
require "bundler/setup"



#Carrega as configurações do config.yml:
config = YAML.load_file('config.yml')

#Configurações do Sinatra
set :server, %w[thin mongrel webrick]
set :bind, config['database']['bind']

#Descomentar para ativar log do banco de dados. 
#DataMapper::Logger.new($stdout, :debug)

#URL básica do banco de dados
url = "mysql://#{config['database']['user']}:#{config['database']['password']}@#{config['database']['host']}/"

#Configura o banco de dados 
DataMapper.setup(:default, url + config['default_redmine']['db_name'])
DataMapper.setup(:pd, url + config['pd_redmine']['db_name'])

#Require models
Dir.glob(File.expand_path("../models/project.rb", __FILE__)).each do |file|
  require file
end

# class Activity
# 	include DataMapper::Resource
# 	property :id, Serial
# end

#Indica o fim da configuração do banco:
DataMapper.finalize

#Mapeamento das rotas
get '/' do
	erb :index
end

get '/teste' do 
	erb :teste
end

post '/worksheet' do
	#Format the date to display:
	@to_date = DateTime.strptime(params[:to],'%Y-%m-%d').strftime('%d/%m/%Y')
	@from_date = DateTime.strptime(params[:from],'%Y-%m-%d').strftime('%d/%m/%Y')

	@time_entries = []
		if authenticate_user(params[:login], params[:password])
			@user = get_user(params[:login])
			DataMapper.repository(:default){ @time_entries += get_time_entries(@user[:id], params[:from], params[:to]) }
			DataMapper.repository(:pd){ @time_entries += get_time_entries(@user[:pd_id], params[:from], params[:to], true) }
			@time_entries = @time_entries.group_by{ |te| te.spent_on}
			erb :worksheet
		else
			params[:alert] = "Usu&aacute;rio e senha inv&aacute;lidos"
			erb :index
		end
end

#Metodos auxiliares
def get_time_entries(id, from, to, pd=false)
	time_entries = TimeEntry.all(user_id: id, :spent_on.gte => from, :spent_on.lte => to)
	time_entries.each do |te|
		te.project
		te.user
		te.issue
		te.project
		te.pd = pd
	end
end

def get_user(login)
	user_default = {}
	user_pd = {}
	DataMapper.repository(:default){ user_default = User.first(login: login)}
	DataMapper.repository(:pd){ user_pd = User.first(login: login)}
	user = {}
	user[:login] = user_default.login
	user[:name] = "#{user_default.firstname} #{user_default.lastname}"
	user[:id] = user_default.id
	user[:pd_id] = user_pd.id if user_pd
	return user	
end

def authenticate_user(login, password)
  profiles = [ ["fwork", 1], ["marketing", 2], ["p_optidata", 3], ["p_rfms", 4], ["webmaster", 5] ]

  user = nil
  user_profiles = []
  ldap_login = "uid=#{login},ou=users,dc=fiberwork,dc=net"
  treebase = "dc=fiberwork,dc=net"
  
  require 'net/ldap'
  ldap =
  #Configura conexao base do servidor LDAP
  Net::LDAP.new(
    :host => "192.168.1.2",
    :port => 389,
    :base => treebase, 
    :auth => { :method => :simple, :username => ldap_login, :password => password.to_s}
  )

  #Se encontrou usuario, inicia o set      
  return ldap.bind
end

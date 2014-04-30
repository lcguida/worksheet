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
set :port, config['database']['port']

#Descomentar para ativar log do banco de dados. 
#DataMapper::Logger.new($stdout, :debug)

#URL básica do banco de dados
url = "mysql://#{config['database']['user']}:#{config['database']['password']}@#{config['database']['host']}/"

#Configura o banco de dados 
DataMapper.setup(:default, url + config['default_redmine']['db_name'])
DataMapper.setup(:pd, url + config['pd_redmine']['db_name'])

#Mapeamento das tabelas:
class TimeEntry
	include DataMapper::Resource
	property :id, Serial
	property :hours, Float
	property :comments, String
	property :spent_on, DateTime

	belongs_to :user
	belongs_to :project
	belongs_to :issue
	# belongs_to :activity

	#Flag para indicar que a issue é do Redmine P&D
	attr_accessor :pd

	#Constói o link para a issue
	def get_issue_link
		"http://192.168.1.2:30#{pd ? 40 : 30}/issues/#{issue.id}"
	end

	#Constói o link para o projeto
	def get_project_link
		"http://192.168.1.2:30#{pd ? 40 : 30}/projects/#{project.identifier}"
	end
end

class Project
	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :identifier, String
end

class User
	include DataMapper::Resource
	property :id, Serial
	property :login, String
	property :firstname, String
	property :lastname, String
end

class Issue
	include DataMapper::Resource
	property :id, Serial
	property :subject, String
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

post '/worksheet' do 
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


###################################################################################
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
    #   uidnumber = nil

    #   #Busca o uid do login
    #   filter = Net::LDAP::Filter.eq("uid", login)
    #   #ldap.search(:base => LDAP_TREEBASE, :filter => filter, :attributes => ["uidnumber"]) { |entry| uidnumber = entry.uidnumber.first }
      
    #   user = User.find_by_login(login)

    #   unless user
    #     user = 
    #     User.create(
    #       :name => login,
    #       :login => login,
    #       :password => login,
    #       :email => login,
    #       :notes => "LDAP User"
    #     )
    #   end
      
    #   #user.id = uidnumber.to_i

    #   #Percorre cada perfil/grupo pra verificar se ha o login/usuario como membro do grupo
    #   profiles.each do |p|
    #     profile = p[0].to_s #nome do grupo
    #     val = p[1].to_i #valor do grupo
    #     #Gera a arvore base do diretorio do grupo da iteracao
    #     # if (ENV['RAILS_ENV']=="prodution")
    #       treebase = "cn=#{profile},ou=groups," + LDAP_TREEBASE
    #     # else
    #     #   treebase = "cn=#{profile},ou=groups," + LDAP_TREEBASE
    #     # end
    #     ldap.search(:base => treebase) do |entry|


    #       logger.debug "========================================="
    #       entry.each do |attribute, values|
    #         logger.debug("#{attribute} => #{values}")
    #       end

    #       entry.memberuid.each do |member|
    #         user_profiles << val if member.to_s == login.to_s #Se o usuario e membro, adiciona o val do profile em seu array
    #       end
    #     end
    #   end
    # user_profiles << 0 unless (ENV['RAILS_ENV']=="prodution")#Comment this line to get LDAP profiles
    # return user, user_profiles
  end
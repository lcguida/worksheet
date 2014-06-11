require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'net/ldap'
require "bundler/setup"

#Carrega arquivos de configurações:
config = YAML.load_file('config.yml')

#Configurações do Sinatra
set :server, %w[thin mongrel webrick]
set :bind, config['bind'] ||= "localhost"

#Load Database Configuration
require_relative "database_setup.rb"

#Mapeamento das rotas
get '/' do
	@users = User.get_all_users
	erb :index
end

post '/worksheet' do
	#Date Formatting
	@to_date = DateTime.strptime(params[:to],'%Y-%m-%d').strftime('%d/%m/%Y')
	@from_date = DateTime.strptime(params[:from],'%Y-%m-%d').strftime('%d/%m/%Y')

	@user = User.first({login: params[:login]}) 
	user_login = params[:user_login] == "myself" ? @user.login : params[:user_login]

	@time_entries = []
		if @user.authenticate(params[:password]) #TODO: Pesquisar como evitar SQL Injection no Sinatra
			if @user.login == user_login || @user.admin
				DataMapper::Repository.adapters.keys.each do |repository|		
					DataMapper.repository(repository){ 
						@time_entries += TimeEntry.get_users_time_entry(user_login, params[:from], params[:to]) 
					}
				end
				@time_entries = @time_entries.group_by{ |te| te.spent_on}
				erb :worksheet
			else
				params[:alert] = "Voc&ecirc; n&acirc; tem permiss&acirc;o para visualizar as horas do usu&agrave;io #{user_login}"
				@users = User.get_all_users #TODO: Como posso redirecionar para '/' passando parametros
				erb :index
			end
		else
			params[:alert] = "Usu&aacute;rio e senha inv&aacute;lidos"
			@users = User.get_all_users
			erb :index
		end
end


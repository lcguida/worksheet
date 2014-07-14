require 'rubygems'
require 'sinatra'
require 'data_mapper'
require "bundler/setup"

#Carrega arquivos de configurações:
config = YAML.load_file('config.yml') if File.exist?('config.yml')

#Configurações do Sinatra
set :server, %w[thin mongrel webrick]
set :bind, config ? config['bind'] : "localhost"

#Load libs:
Dir.glob(File.expand_path("../lib/*.rb", __FILE__)).each do |file|
  require file
end

#Load Database Configuration
require_relative "database_setup.rb"

#Mapeamento das rotas
get '/' do
	@users = User.get_all_users
	erb :index
end

get '/admin' do
	@groups = User.get_all_groups
	erb :admin
end

post '/worksheet' do	
	@to_date, @from_date  = get_formatted_dates(params[:to], params[:from])

	@user = User.first({login: params[:login]}) 
	user_login = params[:user_login] == "myself" ? @user.login : params[:user_login]

	@time_entries = []
		if @user.authenticate(params[:password]) #TODO: Pesquisar como evitar SQL Injection no Sinatra
			if @user.login == user_login || @user.admin
				DataMapper::Repository.adapters.keys.each do |repository|		
					DataMapper.repository(repository){ 
						@time_entries += TimeEntry.get_user_time_entries(user_login, params[:from], params[:to]) 
					}
				end
				@time_entries = @time_entries.group_by{ |te| te.spent_on}
				erb :worksheet
			else
				params[:alert] = "Voc&ecirc; n&acirc; tem permiss&acirc;o para visualizar as horas do usu&agrave;io #{user_login}"
				@users = User.get_all_users
				erb :index
			end
		else
			params[:alert] = "Usu&aacute;rio e senha inv&aacute;lidos"
			@users = User.get_all_users
			erb :index
		end
end

post '/workload' do
	@to_date = DateTime.strptime(params[:to],'%Y-%m-%d').strftime('%d/%m/%Y')
	@from_date = DateTime.strptime(params[:from],'%Y-%m-%d').strftime('%d/%m/%Y')

	logins = GroupsUser.get_users_logins(params[:group_id])

	time_entries = []
	DataMapper::Repository.adapters.keys.each do |repository|		
		DataMapper.repository(repository){ 
			time_entries += TimeEntry.get_group_time_entries(logins, params[:from], params[:to]) 
		}
	end

	puts "Time Entries Size: #{time_entries.size}"

	#WorkLoad per user
	@users_time_entries = time_entries.group_by { |te| te.user}

	#Total Workload
	@total_workload = time_entries.inject(0){ |total, time_entry| total + time_entry.hours}

	#Workload per project
	@project_time_entries = Workload.per_project(time_entries, @total_workload)

	erb :workload
end

private 
def get_formatted_dates (to, from)
	to_date = DateTime.strptime(to,'%Y-%m-%d').strftime('%d/%m/%Y')
	from_date = DateTime.strptime(from,'%Y-%m-%d').strftime('%d/%m/%Y')	
	return to_date, from_date
end

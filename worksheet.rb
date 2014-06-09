require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'net/ldap'
require "bundler/setup"

#Carrega arquivos de configurações:
config = YAML.load_file('config.yml')
database = YAML.load_file('database.yml')
repositories = []

#Configurações do Sinatra
set :server, %w[thin mongrel webrick]
set :bind, config['bind'] ||= "localhost"

#Descomentar para ativar log do banco de dados. 
DataMapper::Logger.new($stdout, :debug)

#Configura DataMappers com as informações do arquivo database.yml
database.each do |database, configs|
	repositories << database.to_sym
	DataMapper.setup(database.to_sym, configs)
end

#Importa os models
Dir.glob(File.expand_path("../models/*.rb", __FILE__)).each do |file|
  require file
end

#Indica o fim da configuração do banco:
DataMapper.finalize

#Mapeamento das rotas
get '/' do
	@users = User.all(:login.not => "")
	erb :index
end

post '/worksheet' do
	#Formatação da Data
	@to_date = DateTime.strptime(params[:to],'%Y-%m-%d').strftime('%d/%m/%Y')
	@from_date = DateTime.strptime(params[:from],'%Y-%m-%d').strftime('%d/%m/%Y')

	@user = User.first({login: params[:login]}) 
	user_login = params[:user_login] == "myself" ? @user.login : params[:user_login]

	@time_entries = []
		if @user.authenticate(params[:password]) #TODO: Pesquisar como evitar SQL Injection no Sinatra
			puts "#{@user.login} != #{user_login}: #{(@user.login != user_login).to_s}"
			puts "AND: #{@user.admin.to_s}"
			if @user.login == user_login || @user.admin

				#TODO: como posso pegar a lista de respositótios direto do DataMapper
				repositories.each do |repository|		
					DataMapper.repository(repository){ @time_entries += TimeEntry.get_users_time_entry(user_login, params[:from], params[:to]) }
				end
				@time_entries = @time_entries.group_by{ |te| te.spent_on}
				erb :worksheet
			else
				params[:alert] = "Voc&ecirc; n&acirc; tem permiss&acirc;o para visualizar as horas do usu&agrave;io #{user_login}"
				@users = User.all(:login.not => "") #TODO: Como posso redirecionar para '/' passando parametros
				erb :index
			end
		else
			params[:alert] = "Usu&aacute;rio e senha inv&aacute;lidos"
			@users = User.all(:login.not => "")
			erb :index
		end
end


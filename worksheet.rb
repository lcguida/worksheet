require 'rubygems'
require 'sinatra'
require 'data_mapper'

set :server, %w[thin mongrel webrick]
#set :bind, '192.168.1.2'
#set :port, 3060

#Loga os acessos ao banco
#DataMapper::Logger.new($stdout, :debug)

#Configura o banco de dados 
DataMapper.setup(:default, 'mysql://root:123456@192.168.1.2/redmine')
DataMapper.setup(:pd, 'mysql://root:123456@192.168.1.2/redmine_pd')

#Mapeamento das tabelas:
class TimeEntry
	include DataMapper::Resource
	property :id, Serial
	property :hours, Float
	property :comments, String
	property :activity_id, Integer #Require the Activity Table
	property :spent_on, DateTime

	belongs_to :user
	belongs_to :project
	belongs_to :issue

	attr_accessor :pd

	def get_issue_link
		"http://192.168.1.2:30#{pd ? 40 : 30}/issues/#{issue.id}"
	end

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

#Indica o fim da configuração do banco:
DataMapper.finalize

#Mapeamento das rotas
get '/' do
	erb :index
end

get '/worksheet' do 
	@time_entries = []
	@user = get_user(params[:login])
	DataMapper.repository(:default){ @time_entries += get_time_entries(@user[:id], params[:from], params[:to]) }
	DataMapper.repository(:pd){ @time_entries += get_time_entries(@user[:pd_id], params[:from], params[:to], true) }
	@time_entries = @time_entries.group_by{ |te| te.spent_on}
	erb :worksheet
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
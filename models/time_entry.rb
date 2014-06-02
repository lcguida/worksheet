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
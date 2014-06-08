class TimeEntry
	include DataMapper::Resource

	#Campos do banco
	property :id, Serial
	property :hours, Float
	property :comments, String
	property :spent_on, DateTime

	#Associações
	belongs_to :user
	belongs_to :project
	belongs_to :issue
	belongs_to :activity

	#Busca as Time Entries de um determinado usuário
	def self.get_users_time_entry(login, start_date, end_date)
		conditions = {:user => {:login => login}, :spent_on.gte => start_date, :spent_on.lte => end_date}
		entries = self.all(conditions)

		#Carrega as dependências. Pesquisei e não existe
		#um mode de fazer eager loading.
		entries.each do |entry|
			entry.project
			entry.user
			entry.issue
			entry.project
		end
	end
end
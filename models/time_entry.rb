class TimeEntry
	include DataMapper::Resource

	property :id, Serial
	property :hours, Float
	property :comments, String
	property :spent_on, DateTime

	
	belongs_to :user
	belongs_to :project
	belongs_to :issue
	belongs_to :activity

	#Retrieves User's time entries
	def self.get_user_time_entries(login, start_date, end_date)
		conditions = {:user => {:login => login}, :spent_on.gte => start_date, :spent_on.lte => end_date}
		entries = get_time_entries(conditions)
	end

	#Retrieves all Time entries for a group of users
	def self.get_group_time_entries(logins, start_date, end_date)
		ids = User.all(login: logins).collect {|user| user.id} #GroupsUser.all(group_id: group_id).collect{|group_user| group_user.user_id}
		puts ids.to_s
		conditions = {:user => {:id => ids}, :spent_on.gte => start_date, :spent_on.lte => end_date}
		entries = get_time_entries(conditions)
	end

	private 
	def self.get_time_entries(conditions)
		entries = self.all(conditions)

		#Eager Loading
		entries.each do |entry|
			entry.project
			entry.user
			entry.issue
			entry.project.centro_de_custo =  entry.project.get_centro_de_custo
		end
	end
end
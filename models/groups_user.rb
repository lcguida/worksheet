class GroupsUser 
	include DataMapper::Resource

	property :group_id, Integer, :key => true
	property :user_id, Integer, :key => true

	belongs_to :user
	belongs_to :group, 'User'

	def self.get_users_logins(group_id)
		user_ids = self.all(group_id: group_id).collect{ |group_user| group_user.user_id }
		User.all(id: user_ids).collect{ |user| user.login }
	end
end
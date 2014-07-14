class User
	include DataMapper::Resource
	property :id, Serial
	property :login, String
	property :firstname, String
	property :lastname, String
	property :hashed_password, String
	property :salt, String
	property :admin, Boolean
	property :type, String

	has n, :groups_users

	#Authenticates User
	def authenticate(password)
		Digest::SHA1.hexdigest("#{salt}#{Digest::SHA1.hexdigest(password)}") == hashed_password
	end

	def name
		"#{firstname} #{lastname}"
	end

	def self.get_all_users
		User.all(conditions: {:login.not => "", :type.not => "Group"}, order: :firstname.asc)
	end

	def self.get_all_groups
		User.all(type: "Group", order: :lastname.asc)
	end
end
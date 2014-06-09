class User
	include DataMapper::Resource
	property :id, Serial
	property :login, String
	property :firstname, String
	property :lastname, String
	property :hashed_password, String
	property :salt, String
	property :admin, Boolean

	#Autentica a senha do usuário
	def authenticate(password)
		Digest::SHA1.hexdigest("#{salt}#{Digest::SHA1.hexdigest(password)}") == hashed_password
	end

	def name
		"#{firstname} #{lastname}"
	end

	def self.get_all_users
		User.all(:login.not => "", :order => :firstname.asc)
	end
end
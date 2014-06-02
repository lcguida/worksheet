class User
	include DataMapper::Resource
	property :id, Serial
	property :login, String
	property :firstname, String
	property :lastname, String
end
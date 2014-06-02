class Project
	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :identifier, String
end
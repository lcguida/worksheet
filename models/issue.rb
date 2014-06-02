class Issue
	include DataMapper::Resource
	property :id, Serial
	property :subject, String
end	
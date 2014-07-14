class CustomField
	include DataMapper::Resource

	property :id, Serial
	property :name, String

	has n, :custom_values
end
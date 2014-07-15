class CustomValue
	include DataMapper::Resource

	property :id, Serial
	property :value, String
	property :customized_type, String

	belongs_to :project, model: 'Project', child_key: :customized_id
	belongs_to :custom_field
end


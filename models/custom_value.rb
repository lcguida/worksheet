class CustomValue
	include DataMapper::Resource

	property :value, String
	property :custom_field_id, Integer, key: true

	belongs_to :project, model: 'Project', child_key: :customized_id
	belongs_to :custom_field
end


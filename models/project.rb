class Project
	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :identifier, String

	attr_accessor :centro_de_custo

	def get_centro_de_custo
		centro_de_custo = CustomValue.all({customized_id: self.id, custom_field: {name: "Centro de Custo"}})
		return centro_de_custo.empty? ? "000.000 (INVÁLIDO)" : centro_de_custo.first.value
	end
end
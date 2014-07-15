# encoding: UTF-8
class Project
	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :identifier, String

	attr_accessor :centro_de_custo

	def get_centro_de_custo
		centro_custo = CustomValue.all({customized_id: self.id, customized_type: "Project", custom_field: {name: "Centro de Custo"}})
		return centro_custo.empty? ? "000.000 (INVÁLIDO)" : centro_custo.first.value
	end
end
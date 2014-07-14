module Workload

	#Retrieves an array of hash with the following fields:
	# - project_name -> Project's name
	# - centro_de_custo -> Project's centro de custo
	# - project_total_hours -> Total hours worked in the projects
	# - percentage -> Percentage of project total hours in the overwall total hours
	def self.per_project(time_entries, total)
		workloads = []
		time_entries.group_by{ |time_entry| time_entry.project}.each do |project, tentry|
			project_total_hours = tentry.inject(0){ |total, te| total + te.hours}
			workloads << {
				project_name: project.name,
				centro_de_custo: project.centro_de_custo,
				project_total_hours: project_total_hours,
				percentage: (project_total_hours.to_f/total.to_f) * 100.0
			}
		end
		return workloads
	end

end
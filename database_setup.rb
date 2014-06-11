#Load databsse configs
database = YAML.load_file('database.yml')

#Import Database Models
Dir.glob(File.expand_path("../models/*.rb", __FILE__)).each do |file|
  require file
end

#Database Loggin
#DataMapper::Logger.new($stdout, :debug)

#Configures production database(s)
configure :production do
	database.each { |database, configs| DataMapper.setup(database.to_sym, configs) }
end

#Configures testing database
configure :test do 
	DataMapper.setup(:default, "sqlite::memory")
	DataMapper.auto_migrate!
end

#Finalize DataMapper configuration
DataMapper.finalize
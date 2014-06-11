require_relative 'spec_helper.rb'

describe "Worksheet" do

	it 'should print "No time entries found" when there\'s none' do
		user = User.new
		user.login = "user"
		user.firstname = "User"
		user.lastname = "Foo"
		user.salt = Digest::SHA1.hexdigest("salt")
		user.hashed_password = Digest::SHA1.hexdigest("#{user.salt}#{Digest::SHA1.hexdigest("password")}")
		user.admin = false
		user.save

		post '/worksheet', {login: user.login, password: "password", from: "2014-05-01", to: "2014-05-10"}
		assert last_response.ok?, "request didn't responded OK"
		assert last_response.body.include?("<h4> Não há registro de horas para o período especificado</h4>"), "response doesn't have 'no record found' message"
	end
end
require_relative '../spec_helper.rb'

describe User do

	before do
		@user = User.new
		@user.login = "@user"
		@user.firstname = "Foo"
		@user.lastname = "Bar"
		@user.salt = Digest::SHA1.hexdigest("salt")
		@user.hashed_password = Digest::SHA1.hexdigest("#{@user.salt}#{Digest::SHA1.hexdigest("password")}")
		@user.admin = false
		@user.type = "User"
		@user.save
	end

	after do 
		@user.destroy!
	end

	it "should print full name"	do
		assert @user.name == "Foo Bar", "Incorrect user full name"
	end

	it "should authenticate" do
		assert @user.authenticate("password"), "User wasn't authenticated"
	end

	it "should retrieve all users with a login" do
		User.create(firstname: "No", lastname: "Login", type: "User")
		User.create(firstname: "Another", lastname: "User", login: "anotheruser", type: "User")

		assert User.get_all_users.size == 2, "User count should be 2"
	end
end
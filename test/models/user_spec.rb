require_relative '../spec_helper.rb'

describe "User" do

	before do
		@user = User.new
		@user.login = "@user"
		@user.firstname = "Foo"
		@user.lastname = "Bar"
		@user.salt = Digest::SHA1.hexdigest("salt")
		@user.hashed_password = Digest::SHA1.hexdigest("#{@user.salt}#{Digest::SHA1.hexdigest("password")}")
		@user.admin = false
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
end
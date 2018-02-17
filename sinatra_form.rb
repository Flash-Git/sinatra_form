require 'sinatra'

enable :sessions

def store_name(filename, string)
	File.open(filename, "a+") do |file|
		file.puts(string)
	end
end

def read_names
	return [] unless File.exist?("names.txt")
	File.read("names.txt").split("\n")
end

get "/form" do
  @message = session.delete(:message)
  @name = params["name"]
  @names = read_names	
  erb :sinatra_form
end

class NameValidator
	def initialize(name, names)
		@name = name.to_s
		@names = names
	end

	def valid?
		validate
		@message.nil?
	end

	def message
		@message
	end

	private def validate
		if @name.empty?
			@message = "You need to enter a name."
		elsif @names.include?(@name)
			@message = "#{@name} is already in our list."
		end
	end
end

post "/form" do
   	@name = params["name"]
   	@names = read_names
 	validator = NameValidator.new(@name, @names)
  	if validator.valid?
   		store_name("names.txt", @name)
   		session[:message] = "Successfully stored the name #{@name}."
 		redirect "/form?name=#{@name}"
 	else
 		session[:message] = validator.message
 		erb :sinatra_form
 	end
 	redirect "/form?name=#{@name}"
 end
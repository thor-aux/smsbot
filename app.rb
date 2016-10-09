require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

# Load configuration from system environment variables - see the README for more
# on these variables.
TWILIO_ACCOUNT_SID = ENV['TWILIO_ACCOUNT_SID'] || "ACdc4c43e886f4707e22faf156f843db02"
TWILIO_AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN'] || "3dfbd55ed218936d816e58f127a7ac52"
TWILIO_NUMBER = ENV['TWILIO_NUMBER'] || "2569989418"

set :bind, '0.0.0.0'
set :port, ENV['TWILIO_STARTER_RUBY_PORT'] || 4567

# Create an authenticated client to call Twilio's REST API
client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN

# Sinatra route for your app's home page at "http://localhost:4567/" or your
# public web server
get '/' do
  erb :index
end

# Handle a form POST to send a message
post '/message' do
  # Use the REST API client to send a text message
  client.account.sms.messages.create(
    :from => TWILIO_NUMBER,
    :to => params[:to],
    :body => 'DOH!'
  )

  # Send back a message indicating the text is inbound
  'Message on the way!'
end

# Handle a form POST to make a call
post '/call' do
  # Use the REST API client to make an outbound call
  client.account.calls.create(
    :from => TWILIO_NUMBER,
    :to => params[:to],
    :url => 'http://twimlets.com/message?Message%5B0%5D=http://demo.kevinwhinnery.com/audio/zelda.mp3'
  )

  # Send back a text string with just a "hooray" message
  'Call is inbound!'
end

post '/bot' do
  puts params.inspect

  msgin = params[:body]

  case msgin
  when /joke/
   msgout = "Yo Momma"
  when /tell.*joke/
   msgout = "Zombies like brains... oh wait, that's not a joke... that's a warning"
  when /[Aa]ri/
   msgout = "Yep"
  else 
   msgout = "Thanks for your message: " + msgin 
  end

  client.account.sms.messages.create(
    :from => TWILIO_NUMBER,
    :to => params[:from],
    :body => msgout
  )


end

# Render a TwiML document that will say a message back to the user
get '/hello' do
  # Build a TwiML response
  response = Twilio::TwiML::Response.new do |r|
    r.Say 'Hello there! You have successfully configured a web hook.'
    r.Say 'Good luck on your Twilio quest!', :voice => 'woman'
  end

  # Render an XML (TwiML) document
  content_type 'text/xml'
  response.text
end

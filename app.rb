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
  # {"ToCountry"=>"US", "ToState"=>"AL", "SmsMessageSid"=>"SMd89fb0d41c6fe0ea29a752d4eec7a36e", "NumMedia"=>"0", "ToCity"=>"ATHENS", "FromZip"=>"10010", "SmsSid"=>"SMd89fb0d41c6fe0ea29a752d4eec7a36e", "FromState"=>"NY", "SmsStatus"=>"received", "FromCity"=>"NEW YORK", "Body"=>"Again", "FromCountry"=>"US", "To"=>"+12569989418", "ToZip"=>"35611", "NumSegments"=>"1", "MessageSid"=>"SMd89fb0d41c6fe0ea29a752d4eec7a36e", "AccountSid"=>"ACdc4c43e886f4707e22faf156f843db02", "From"=>"+19175932024", "ApiVersion"=>"2010-04-01"}

  puts params.inspect

  msgin = params[:Body]

  case msgin
  when Regexp.new("tell.*joke", Regexp::IGNORECASE)
   jokes = ["Zombies like brains... oh wait, that's not a joke... that's a warning",
   			"Whats a zombies favorite food? Man-gos!",
   			"It must be hard for dna, all crammed up in there wondering Does this jean make my but look fat?"
   		]
   msgout = jokes.sample
  when Regexp.new("joke", Regexp::IGNORECASE)
   msgout = "Yo Momma"
  when Regexp.new("you", Regexp::IGNORECASE)
   msgout = "I'm great. How are you?"
  when Regexp.new("yo", Regexp::IGNORECASE)
   msgout = "Yo... who? Yo Momma"
  when /[Aa]ri/
   msgout = "Yep, you guessed it"
  when Regexp.new("what color ['are''is']", Regexp::IGNORECASE)
  	msgout = "0xAAAA05"
  when Regexp.new("how are .* made", Regexp::IGNORECASE)
  	msgout = 'With 1 and 0 and alot of star dust'
  when Regexp.new('do you.* love me')
  	msgout = "Why yes, of course"
  when Regexp.new('love')  	
  	msgout = "L = 8 + .5Y - .2P + .9Hm + .3Mf + J - .3G - .5(Sm - Sf)2 + I + 1.5C"
  else 
   msgout = msgin + " Does not compute." 
  end

  client.account.sms.messages.create(
    :from => TWILIO_NUMBER,
    :to => params[:From],
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

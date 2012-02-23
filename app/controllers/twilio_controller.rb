require 'twilio-ruby'

# your Twilio authentication credentials
ACCOUNT_SID = 'AC5cb9a6dcffb746ada26419b0b9621989'
ACCOUNT_TOKEN = '4ad536d882cdcf07f36876f264ee560d'

# version of the Twilio REST API to use
API_VERSION = '2010-04-01'

# base URL of this application
BASE_URL =  "http://pandorify.heroku.com/home" #production ex: "http://appname.heroku.com/callme"

# Outgoing Caller ID you have previously validated with Twilio
CALLER_ID = '949-272-0608'

class TwilioController < ApplicationController

  # {"AccountSid"=>"AC5cb9a6dcffb746ada26419b0b9621989", "Body"=>"test", "ToZip"=>"92677", "FromState"=>"CA", "ToCity"=>"LAGUNA NIGUEL", "SmsSid"=>"SM7ac62fadfde51b614605c1e830c9d395", "ToState"=>"CA", "To"=>"+19492720608", "ToCountry"=>"US", "FromCountry"=>"US", "SmsMessageSid"=>"SM7ac62fadfde51b614605c1e830c9d395", "ApiVersion"=>"2010-04-01", "FromCity"=>"IRVINE", "SmsStatus"=>"received", "From"=>"+19492664898", "FromZip"=>"92606", "controller"=>"call", "action"=>"sms"}
  def sms
    body = params["Body"].downcase.strip
    # number = params["From"]
    # user = Facebook.find_by_cell(number)
    # party = user.parties.first
    # 
    # if party
      url = "http://ws.spotify.com/search/1/track?q=#{self.get_uri}"
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request).body
      @new_info = JSON.parse(response)
    # end

    # @client = Twilio::REST::Client.new ACCOUNT_SID, ACCOUNT_TOKEN
    # @client.account.sms.messages.create(
    #   :from => "+19492720608",
    #   :to => number,
    #   :body => @body
    # )
    
    respond_to do |format|
       format.js
       format.json{
         render :json => @new_info
       }
    end
    
  end

end

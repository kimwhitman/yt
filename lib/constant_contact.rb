require 'builder'
require 'rest_client'
module ConstantContact
  class << self
    API_KEY = '5d1430cb-4039-45a0-bf12-2f08aec779b3'
    USERNAME = 'yogatoday'
    PASSWORD = 'yoga2day'
    def subscribe(user)
      link_id = user_id(user)
      entry = build_xml(link_id) do |xml|
        xml.EmailAddress user.email
        xml.FirstName user.name.split.first
        xml.LastName user.name.split.last
        xml.OptInSource 'ACTION_BY_CONTACT'
        xml.ContactLists do
          xml.ContactList(:id => "http://api.constantcontact.com/ws/customers/#{USERNAME}/lists/1")
        end
      end
      url = link_id || "https://api.constantcontact.com/ws/customers/#{USERNAME}/contacts"
      Rails.logger.debug "Sending to #{url} from ConstantContact##subscribed: #{entry}"
      response = nil
      with_exceptions(user) do
        response = authed_request(url, :method => (link_id.blank? ? :post : :put), :payload => entry).execute
      end
      Rails.logger.debug "Received this response for ConstantContact##subscribed: #{response}"
      
      true
    end
    def unsubscribe(user)
      link_id = user_id(user)
      return true unless link_id
      entry = build_xml(link_id) do |xml|
        xml.EmailAddress user.email
        xml.OptInSource 'ACTION_BY_CONTACT'
        xml.ContactLists
      end
      Rails.logger.debug "Sending to #{link_id} from ConstantContact##unsubscribed: #{entry}"
      response = nil
      with_exceptions(user) do
        response = authed_request(link_id, :method => :put, :payload => entry).execute
      end
      Rails.logger.debug "Received this response for ConstantContact##unsubscribed: #{response}"
      true
    end
    protected
    def with_exceptions(user = nil, &block)
      begin
        block.call
      rescue RestClient::Exception => e
        Rails.logger.info "Call to Constant Contact failed: #{e}"
        Rails.logger.info "User #{user.email} (#{user.id}) had problems updating their subscription info!" if user
        if e.is_a? RestClient::RequestFailed
          Rails.logger.info "Request failed with following details: #{e.response.body}"
        end
      end
    end
    def authed_request(url, opts = {})
      Rails.logger.info "URL is #{url}"
      options = opts.reverse_merge :method => :get,
        :url => url,
        :user => "#{API_KEY}%#{USERNAME}",
        :password => PASSWORD,
        :auth_type => 'basic',
        :headers => {
          'Content-Type' => "application/atom+xml"
        }
      RestClient::Request.new options
    end
    def user_id(user)
      email = user.old_email || user.email
      search_url = "https://api.constantcontact.com/ws/customers/#{USERNAME}/contacts?email=#{CGI::escape(email)}"
      response = nil
      Rails.logger.debug "Sending to #{search_url} from ConstantContact##user_id"
      with_exceptions do
        response = authed_request(search_url).execute
      end
      Rails.logger.debug "Received this response for ConstantContact##user_id: #{response}"
      data = Hash.from_xml response      
      xxx = data['feed']['entry'].blank? ? nil : data['feed']['entry']['id']
      if xxx.nil?
        xxx
      else
        xxx.sub(/^http:/, "https:")
      end
    end
    def build_xml(link_id = nil, &block)
      id = link_id || 'data:,none'
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.entry(:xmlns => "http://www.w3.org/2005/Atom") do
        xml.title(:type => 'text')
        xml.author
        xml.updated DateTime.now.to_s
        xml.id id
        xml.summary(:type => 'text') { 'Contact' }
        xml.content(:type => 'application/vnd.ctct+xml') do          
          xml.Contact(:xmlns => 'http://ws.constantcontact.com/ns/1.0/') do
            block.call(xml)
          end
        end
      end
    end
    end
  end    

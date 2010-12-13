require 'savon'
require 'nokogiri'
require 'gift_card'

# override :wsdl tag being injected
# because complemar webservice doesn't work with it
module Savon
  class SOAP
    def xml_body(xml)
      xml.env(:Body) do
        xml.tag!(*input_array) { xml << (@body.to_soap_xml rescue @body.to_s) }
      end
    end
  end
end

module GiftCardService
  class API

    attr_reader :username, :password, :base_url

    def initialize(url, namespace)
      @client    = Savon::Client.new(url)
      @namespace = namespace
      @username  = 'aghag@complemar.com'
      @password  = 'Computer7*'
      @base_url  = 'http://complemar.com'
      @xmlnses   = { "xmlns" => @namespace }
    end

    def redeem(serial_number, amount)
      response = @client.use_gift_card! do |soap|
        action = 'UseGiftCard'
        soap.namespaces['xmlns']   = "http://complemar.com/"
        soap.input     = [action, @xmlnses]
        soap.action    = "#{base_url}/#{action}"
        soap.body      = {
          "UserName"   => username,
          "Password"   => password,
          "GiftCardSN" => serial_number,
          "amount"     => amount,
          }
      end

      if valid_response?(response)
        result = response.to_hash

        if result.has_key?(:use_gift_card_response) && result[:use_gift_card_response].has_key?(:use_gift_card_result)
          xml = reencode_xml(result[:use_gift_card_response][:use_gift_card_result])

          if xml.css("GIFTCARD ERROR").empty?
            # puts xml.text
            return true
          end

          # puts xml.css("GIFTCARD ERROR").text
        end
      end

      return false
    end

    def search(serial_number)
      response = @client.validate_gift_card! do |soap|
        action = 'ValidateGiftCard'
        soap.namespaces['xmlns'] = "http://complemar.com/"
        soap.input     = [action,  @xmlnses]
        soap.action    = "#{base_url}/#{action}"
        soap.body      = {
          "UserName"   => username,
          "Password"   => password,
          "GiftCardSN" => serial_number
          }
      end

      if valid_response?(response)
        result = response.to_hash

        if result.has_key?(:validate_gift_card_response) && result[:validate_gift_card_response].has_key?(:validate_gift_card_result)
          xml = reencode_xml(result[:validate_gift_card_response][:validate_gift_card_result])

          GiftCard.from_xml(xml)
        end
      end
    end

    def test_connection
      response = @client.hello_world! do |soap|
        soap.namespace = @namespace
        soap.action    = "#{base_url}/HelloWorld"
        soap.body      = {}
      end

      if valid_response?(response)
        result = response.to_hash
        if result.has_key?(:hello_world_response) && result[:hello_world_response].has_key?(:hello_world_result)
          return result[:hello_world_response][:hello_world_result]
        end
      end

      false
    end

    private

    # convert xml into something we can use
    # currently the SOAP service returns UTF-16 encoding
    # converting it to UTF-8 should not bring about any problems
    def reencode_xml(string)
      formatted_xml = Nokogiri::XML(string).to_xml(:encoding => "UTF-8")
      Nokogiri::XML(formatted_xml)
    end
    
    def valid_response?(response)
      if response.http_error?
        # puts response.http_error
        return false
      elsif response.soap_fault?
        # puts response.soap_fault
        return false
      end

      return true
    end
  end

end
require 'test_helper'

class ApiTest < ActiveSupport::TestCase

  include GiftCardService

  def setup
    wsdl_url      = 'http://yogatodayws.complemar.com/Service1.asmx?WSDL'
    soap_endpoint = 'http://yogatodayws.complemar.com/Service1.asmx'
    namespace     = 'http://complemar.com/'
    
    @valid_serial   = 'd515e781-bb2f-4c2f-80ee-ed9fd1bfde81'
    # @valid_serial   = 'c9ef3071-0acf-4476-81de-e22a11a4f2cf'
    
    @invalid_serial = 'INVALID_NUMBER'
    @client         = GiftCardService::API.new(soap_endpoint, namespace)
    
    # turn logging on if you want to see SOAP request/response debugging
    Savon::Request.log = true
    Savon::Response.raise_errors = false
  end

  def test_connection
    assert @client.test_connection
  end

  def test_search_with_no_giftcard_found
    serial_number = '1234'
    gift_card = @client.search(serial_number)
    assert_not_nil gift_card.error
    assert !gift_card.valid?
  end

  def test_search_for_valid_giftcard
    gift_card = @client.search(@valid_serial)
    assert_not_nil gift_card
    assert gift_card.valid?
  end

  # TODO: add gift card that works
  def test_search_with_empty_giftcard
    gift_card = @client.search('')
    assert_not_nil gift_card
    assert_equal false, gift_card.valid?
    assert_equal gift_card.balance, 0
  end

  # TODO: add gift card that works
  # NOTE: must add cart to SOAP server with balance for this to work
  # def test_redeem_card
  #   serial_number = 'c9ef3071-0acf-4476-81de-e22a11a4f2cf'
  #   assert @client.redeem(serial_number, 3)
  # end

  def test_redeem_card_with_no_amount
    serial_number = 'd515e781-bb2f-4c2f-80ee-ed9fd1bfde81'
    assert_equal false, @client.redeem(serial_number, 0)
  end
  
  def test_redeem_with_empty_card
    serial_number = 'd515e781-bb2f-4c2f-80ee-ed9fd1bfde81'
    assert_equal false, @client.redeem(serial_number, 5)
  end

  def test_redeem_with_nonexistent_card
    assert_equal false, @client.redeem(@invalid_serial, 5)
  end
end

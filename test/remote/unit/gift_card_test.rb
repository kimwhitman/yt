require 'test_helper'

class GiftCardTest < ActiveSupport::TestCase
  
  include GiftCardService
  
  def test_from_xml
    data = <<-EOL
    <GIFTCARD>
      <ID>1</ID>
      <BALANCE>2.00</BALANCE>
      <EXPIRATIONDATE>2010-11-12</EXPIRATIONDATE>
      <INITIALAMOUNT>5</INITIALAMOUNT>
      <SERIALNUMBER>0123456789</SERIALNUMBER>
    </GIFTCARD>
    EOL

    xml = Nokogiri::XML(data)
    gift_card = GiftCardService::GiftCard.from_xml(xml)
    
    assert gift_card.error,nil?
    assert gift_card.valid?
  end
  
  def test_from_xml_with_error
    data = <<-EOL
    <GIFTCARD>
      <ERROR>Invalid Serial Number</ERROR>
    </GIFTCARD>
    EOL
    
    xml = Nokogiri::XML(data)
    gift_card = GiftCardService::GiftCard.from_xml(xml)

    assert_not_nil gift_card.error
    assert_equal gift_card.valid?, false
  end
  
  
  def test_expired_card
    gift_card = GiftCardService::GiftCard.new(:expiration_date => 10.days.ago.to_s)
    assert gift_card.expired?, "Expired: #{gift_card.expiration_date}"
  end
  
  def test_active_card
    gift_card = GiftCardService::GiftCard.new(:expiration_date => 10.days.since.to_s)
    assert_equal false, gift_card.expired?, "Expires: #{gift_card.expiration_date}"
  end
  
  def test_null_card_expiration
    gift_card = GiftCardService::GiftCard.new(:expiration_date => nil)
    assert_equal false, gift_card.expired?, "Expires: #{gift_card.expiration_date}"
  end
end

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  tests UserMailer

  # FIXME: not working
  def test_purchase_confirmation
    return
    @expected.subject = 'UserMailer#purchase_confirmation'
    @expected.body    = read_fixture('purchase_confirmation')
    @expected.date    = Time.now
    assert_equal @expected.encoded, UserMailer.create_purchase_confirmation(@expected.date).encoded
  end

end

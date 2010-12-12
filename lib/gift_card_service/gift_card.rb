require 'api'
require 'date'

module GiftCardService
  class GiftCard

    attr_reader :id, :balance, :expiration_date, :initial_amount, :serial_number, :error
    
    def initialize(attributes)
      @id              = attributes[:id]
      @balance         = attributes[:balance].to_f
      @initial_amount  = attributes[:initial_amount].to_f
      @serial_number   = attributes[:serial_number]
      @error           = attributes[:error]

      begin
        @expiration_date = Date.parse(attributes[:expiration_date]) if attributes[:expiration_date]
      rescue ArgumentError
        @expiration_date = nil
      end
    end

    # <GIFTCARD>
    #   <ID></ID>
    #   <BALANCE></BALANCE>
    #   <EXPIRATIONDATE></EXPIRATIONDATE>
    #   <INITIALAMOUNT></INITIALAMOUNT>
    #   <SERIALNUMBER></SERIALNUMBER>
    # </GIFTCARD>
    def self.from_xml(xml)
      gc = xml.css("GIFTCARD")
      new(
        :id              => gc.css("ID").text,
        :balance         => gc.css("BALANCE").text,
        :expiration_date => gc.css("EXPIRATIONDATE").text,
        :initial_amount  => gc.css("INITIALAMOUNT").text,
        :serial_number   => gc.css("SERIALNUMBER").text,
        :error           => gc.css("ERROR").text
      )
    end

    def valid?
      error.nil? || error.to_s.length == 0
    end
    
    def expired?
      expiration_date.is_a?(Date) && expiration_date < Date.today
    end
    
  end
end

class Money
  include Comparable
  attr_reader :amount
  def initialize(amount = 0)
    @amount = amount
  end
  def to_dollars
    @amount / 100.0
  end
  def to_pennies
    @amount
  end
  # Comparable
  def ==(other_money)
    amount == other_money.amount
  end
  def <=>(other_money)
    amount <=> other_money.amount
  end
  # Math
  def + (other_money)
    Money.new(amount + other_money.amount)
  end
end
# Class containing reserve data and draw card methods.
# @attr reserve [Array<Array(Integer, String)>] Array of card ids
class Reserve
  attr_reader :reserve

  # Complies array of card ids from Deck module.
  def initialize
    @reserve = Deck.id_array
  end

  # Returns and reduces the reserve by a random card.
  # @return [Array(Integer, String), nil] Selected card, or nil if reserve empty
  def draw_card
    card = @reserve.sample
    @reserve -= [card]
    return card
  end

  # Calls draw_card instance method six time to create a hand
  # and deletes any nil elements that may arise from empty array.
  #
  # Array#delete_if used over Array#delete due to the latter
  # returning the deleted item rather than the array.
  # @return [Array<Array(Integer, String)>] Array of six randomly selected cards
  def create_hand
    hand = []
    6.times { hand << draw_card }
    return hand.delete_if { |card| card == nil }.sort
  end
end
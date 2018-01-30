# Class for access to player data.
#
# nil or duplicate items in a players hand are dealt with when
# using add_card and take_card instance methods.
# @attr num [Integer] A player's num
# @attr hand [Array<Array(Integer, String)>] Array of cards in a player's hand
class Player
  attr_reader :num, :hand

  def initialize(num, hand)
    @hand = hand
    @num = num
  end

  # Adds card to player's hand, removes nil elements, sorts hand
  # and deletes any possible duplicates (for safe measure).
  #
  # Array#delete_if used over Array#delete due to the latter
  # returning the deleted item rather than the array.
  # @param card_id [Array] Specific card id
  def add_card(card_id)
    @hand += [card_id]
    @hand.delete_if { |card| card == nil }.sort!.uniq!
  end

  # Takes card from player's hand, removes nil elements,
  # sorts hand, and deletes any possible duplicates (for safe measure).
  #
  # Array#delete_if used over Array#delete due to the latter
  # returning the deleted item rather than the array.
  # @param (see #add_card)
  def take_card(card_id)
    @hand -= [card_id]
    @hand.delete_if { |card| card == nil }.sort!.uniq!
  end

  # Takes all cards of a set from player's hand.
  # @param set_num [Integer] Specific set number
  def take_set(set_num)
    @hand -= @hand.select { |card| card[0] == set_num }
  end

  # Checks player's hand for card, including adding and taking items, and testing for them.
  # @param (see #add_card)
  # @return [Boolean] Whether or not a player has a card
  def check_card(card_id)
    return @hand.include?(card_id)
  end

  # Checks player's hand for complete sets.
  #
  # Does so by comparing number of cards from set to that sets length.
  # @return [Array<Integer>] Array of complete set's numbers
  def check_sets
    complete_sets = []
    @hand.collect { |card| card[0] }.uniq.each do |set_num|
      if @hand.collect { |card| card[0] }.count(set_num) == Deck.set_data(set_num)[2]
        complete_sets << set_num
      end
    end
    return complete_sets
  end
end
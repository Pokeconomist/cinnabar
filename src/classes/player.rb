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
  # @param card_id [Array(Integer, String)] Specific card id
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

  # Takes all the cards of a set and specified crown set cards from player's hand.
  # @param set_num [Integer] Number of set to remove
  # @param crown_set_cards [Array<Array(Integer, String)>] Array of crown cards to remove
  def take_crown_set(set_num, crown_set_cards)
    @hand -= @hand.select { |card| card[0] == set_num }
    @hand -= crown_set_cards
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

  # TODO: Possibly rewrite this for clarity 2018-01-14

  # Checks player's hand for complete sets using crown set cards, and return them.
  #
  # Does so by comparing number of cards from sets plus crown set, to set length.
  # @return [Array<Array(Integer, Array<Array(4, String)>)>] Array of complete sets and required crown cards
  #   and necessary crown card sets
  def check_crown_sets
    complete_crown_sets = []
    @hand.collect { |card| card[0] }.uniq.delete_if { |e| e == 4 }.each do |set_num|
      if @hand.count { |card| card[0] == set_num || card[0] == 4 } >= Deck.set_data(set_num)[2]
        num_crown_cards = Deck.set_data(set_num)[2] - @hand.collect { |card| card[0] }.count { |n| n == set_num }
        complete_crown_sets << [set_num, @hand.select { |card| card[0] == 4 }.first(num_crown_cards)]
      end
    end
    return complete_crown_sets
  end

  # Checks player's hand for title card.
  # @return [Boolean] Whether or not a player has the cinnabar card
  def check_title
    return @hand.include?([1, "A"])
  end

  # Returns set one cards in a player's hand.
  # @return [Array<Array(1, String)>] Array of set one cards in player's hand
  def check_title_set
    return @hand.select { |card| card[0] == 1 }
  end
end
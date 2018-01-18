# TODO: add 'emulated' card calls for cinnabar plays 2018-01-14
# TODO: recognise completed set as using crown set and remove other cards from play 2018-01-17

# CHRISTMAS UPDATE v1.0
#    *
#   /o\   MERRY
#  /o  \    CHRISTMAS
# /   o \       2017
#   ||

require_relative '.\modules\deck'
require_relative '.\modules\write'
require_relative '.\modules\read'
require_relative '.\core_extensions\array\list'
require_relative '.\core_extensions\string\titleise'

# Class for access to player data.
#
# nil or duplicate items in a players hand are dealt with when
# using add_card and take_card instance methods.
# @attr num [Integer] A player's num
# @attr hand [Array] Array of cards in a player's hand
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

  # Takes all the cards of a set and specified crown set cards from player's hand.
  # @param set_num [Integer] Number of set to remove
  # @param crown_set_cards [Array] Array of crown cards to remove
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
  # @return [Array] Array of complete set's numbers
  def check_sets
    complete_sets = []
    # iterate over unique sets
    @hand.collect { |card| card[0] }.uniq.each do |set_num|
      # count number of cards from unique sets, and compare to set length
      if @hand.collect { |card| card[0] }.count(set_num) == Deck.set_data(set_num)[2]
        complete_sets << set_num
      end
    end
    return complete_sets
  end

  # TODO: Possibly rewrite this for clarity 2018-01-14

  # Checks player's hand for complete sets using crown set cards, and return the first found, or nil.
  #
  # Does so by comparing number of cards from unique sets and crown set to set length.
  # @return [Array, nil] Array of complete set's numbers,
  #   and necessary crown card sets
  def check_crown_sets
    @hand.collect { |card| card[0] }.uniq.delete_if { |e| e == 4 }.each do |set_num|
      if @hand.count { |card| card[0] == set_num || card[0] == 4 } >= Deck.set_data(set_num)[2]
        num_crown_cards = Deck.set_data(set_num)[2] - @hand.collect { |card| card[0] }.count { |n| n == set_num }
        return [set_num, @hand.select { |card| card[0] == 4 }.first(num_crown_cards)]
      end
    end
    return nil
  end

  # Checks player's hand for title card.
  # @return [Boolean] Whether or not a player has the cinnabar card
  def check_cinnabar
    return @hand.include?([1, "A"])
  end

  # Returns set one cards in a player's hand.
  # @return [Array] Array of set one cards in player's hand
  def check_title_set
    return @hand.select { |card| card[0] == 1 }
  end
end

# Class containing reserve data and draw card methods.
# @attr reserve [Array] Array of card ids
class Reserve
  attr_reader :reserve

  # Complies array of card ids from `Deck` module.
  def initialize
    @reserve = Deck.id_array
  end

  # Returns and reduces the reserve by a random card.
  # @return [Array, nil] Selected card, or nil if reserve empty
  def draw_card
    card = @reserve.sample
    @reserve -= [card]
    return card
  end

  # Calls `draw_card` instance method six time to create a hand
  # and deletes any nil elements that may arise from empty array.
  #
  # Array#delete_if used over Array#delete due to the latter
  # returning the deleted item rather than the array.
  # @return [Array] Array of six randomly selected cards
  def create_hand
    hand = []
    6.times { hand << draw_card }
    return hand.delete_if { |card| card == nil }.sort
  end
end



Write.game_setup
num_players = Read.game_setup

reserve = Reserve.new
players = Array.new(num_players) { |i| Player.new(i + 1, reserve.create_hand) }

turn_data = []
turn_num = 1
complete_sets = []
title_active = false

loop do
  players.each do |player|
    Write.complete_sets(complete_sets)
    Write.turn_data(turn_data)
    Write.hold_screen(player.num)
    # loop for calling cards, break if card not taken
    loop do
      Write.hand(player.hand)
      # get called card and player inputs
      called_card = Read.card(player.hand)
      called_player = players[Read.player(num_players, player.num) - 1]
      # check called player for card
      if called_player.check_card(called_card)
        called_player.take_card(called_card)
        player.add_card(called_card)
        card_taken = true
      else
        card_taken = false
      end
      turn_data << {
        card_taken:         card_taken,
        called_player_num:  called_player.num,
        calling_player_num: player.num,
        card:               called_card
      }
      Write.call(card_taken, called_player.num)
      # turn finalisation (if card not taken)
      unless turn_data[-1][:card_taken]
        drawn_card = reserve.draw_card
        player.add_card(drawn_card)
        Write.draw(*drawn_card)
        break unless drawn_card == called_card
      end
    end

    # check for title card if not used already
    if player.check_cinnabar && !title_active
      title_active = Read.cinnabar_prompt
      if title_active
        # take all current set one cards
        (players.reject { |p| p == player }).each do |called_player|
          called_player.check_title_set.each do |card|
            called_player.take_card(card)
            player.add_card(card)
            turn_data << {
              card_taken:         true,
              called_player_num:  called_player.num,
              calling_player_num: player.num,
              card:               card
            }
          end
        end
      end
    end

    # check for complete sets
    unless player.check_sets.empty?
      player.check_sets.each do |set_num|
        play_set = Read.set_prompt(set_num)
        if play_set
          player.take_set(set_num)
          complete_sets << {
            set_num:     set_num,
            player_num:  player.num,
            crown_cards: []
          }
        end
      end
    end

    # check for crown set cards
    until player.check_crown_sets.nil?
      play_set = Read.crown_set_prompt(*player.check_crown_sets)
      if play_set
        complete_sets << {
          set_num:     player.check_crown_sets[0],
          player_num:  player.num,
          crown_cards: player.check_crown_sets[1]
        }
        player.take_crown_set(*player.check_crown_sets)
      end
    end

    turn_num += 1
  end
end
# TODO: complete player /  reserve classes, add game logic 2017-12-19

# Title; Cinnabar
# Author; Soda Adlmayer
# Date of Version; 2017-12-19

require '.\modules\deck.rb'

# class containing individual player data (hand stored as id array)
class Player
  attr_reader :hand

  # creates player objects, drawing six cards
  def initialize(reserve, player_num)
    @hand = Game.create_hand(reserve)
    @player_num = player_num
  end

  # method to give card to player
  def add_card(card_id)
    @hand += [card_id]
    @hand.sort!
  end

  # method to take card from a player
  def take_card(card_id)
    @hand -= [card_id]
    @hand.sort!
  end
end

# class controlling player interaction
class Reserve
  # compile id array for cards for easier used (rather than deck hash)
  def initialize(deck)
    @reserve = []
    deck.each do |set|
      set[:set_data][:set_cards].each do |card|
        @reserve << [set[:set_num], card[:set_pos]]
      end
    end
  end

  # method to return and reduce the reserve by a random card
  def draw_card
    card = @reserve.sample
    @reserve -= [card]
    return card
  end

  # method to create hand TODO: possibly optimise this 2017-12-19
  def create_hand
    hand = []
    6.times { hand << self.draw_card }
    return hand
  end
end
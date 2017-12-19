# TODO: complete player /  reserve classes, add game logic 2017-12-18
# TODO: add player inputs / calls. and complete game logic 2017-12-19

# Title; Cinnabar
# Author; Soda Adlmayer
# Date of Version; 2017-12-19

require '.\modules\deck.rb'

# class containing individual player data (hand stored as id array)
class Player
  attr_reader :hand, :player_num

  # creates player objects, drawing six cards
  def initialize(player_num, hand)
    @hand = hand
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

  # method to check hand for card
  def check_hand(card_id)
    return @hand.include?    
  end 
end

# class controlling reserve access
class Reserve
  attr_reader :reserve

  # compile id array for cards for easier used (rather than deck hash)
  def initialize
    @reserve = Deck.id_array
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
    6.times { hand << draw_card }
    return hand.sort
  end
end

# Handling of Turn Data
# --
# turn_data variable used to specify what occurred during the last turn, and notify other players
# turn_data = [{:card_taken => $bool$, :called_player => $int$, :calling_player => $int$, :card => $arr$}, ...]
# card_taken = true if player [:called_player] has [:card]
# can check for all cases with these variables
# ie.
# :A p call p[n] - (doesn't have card / has card)
#                             |          |-> call again >> turn_data && goto A
#                            \/
#                         end turn
# __thus turn_data[-1][:card_taken] == false for all end cases__

turn = 0

main loop
loop do
  if turn == 0
    # initialise game objects
    reserve = Reserve.new
    player1 = Player.new(1, reserve.create_hand)
    player2 = Player.new(2, reserve.create_hand)
    player3 = Player.new(3, reserve.create_hand)
    players = [player1, player2, player3]
    turn += 1
  end

  # loop for each player
  (0..2).each do |n|
    
    turn +=1
  end
end

# DISPLAY FUNCTIONS

# method to display card data
def write_card(card_id)
  card_name, card_desc, set_name, set_num, set_pos = Deck.card_data(*card_id)
  print "----------------\n"
  Deck.card_set(*card_id).each { |card| print " #{card}\n" }
  print "#{set_name.upcase}    #{set_num}-#{set_pos}\n"
  print "  #{card_name.upcase}\n"
  print "(#{card_desc})\n"
  print "----------------\n"
end


# method to display turn data
def write_turn_data(turn_data)
  if turn_data != []
    turn_data.each do |card|
      if card[:card_taken]
        puts "Player #{card[:calling_player]} took #{Deck.card_data(*card[:card])[0]} from Player #{card[:called_player]}."
      else
        puts "Player #{card[:calling_player]} asked Player #{card[:called_player]} for #{Deck.card_data(*card[:card])[0]} but was denied."
      end
    end
  end
end
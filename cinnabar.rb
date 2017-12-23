# TODO: see .\cinnabar.rb:99 & .\cinnabar.rb:100 2017-12-22
# TODO: add player inputs / calls, and complete game logic 2017-12-19
# TODO: complete player / reserve classes, add game logic 2017-12-18
#
# Title; Cinnabar
# Author; Soda Adlmayer
# Date of Version; 2017-12-22

require '.\modules\deck.rb'
require '.\modules\write.rb'
require '.\modules\read.rb'

Write.test
Read.test
Deck.test

# class containing individual player data
class Player
  attr_reader :hand, :num

  # create player objects, drawing six cards for hand (stored as id array)
  def initialize(num, hand)
    @hand = hand
    @num = num
  end

  # method to give card to player
  def add_card(card_id)
    @hand += [card_id]
    @hand.sort!
  end

  # method to take card from player
  def take_card(card_id)
    @hand -= [card_id]
    @hand.sort!
  end

  # method to check hand for card
  def check_hand(card_id)
    return @hand.include?(card_id)
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
#
# turn_data = [{:card_taken => $bool$, :called_player => $int$, :calling_player => $int$, :card => $arr$}, ...]
#
# card_taken = true if player [:called_player] has [:card]
# can check for all cases with these variables
# ie.
# :A p call p[n] - (doesn't have card / has card)
#                             |          |-> call again >> turn_data && goto A
#                            \/
#                         end turn
# __thus turn_data[-1][:card_taken] == false for all end cases__

# initialise game objects
turn_num = 0
reserve = Reserve.new
player1 = Player.new(1, reserve.create_hand)
player2 = Player.new(2, reserve.create_hand)
player3 = Player.new(3, reserve.create_hand)
players = [player1, player2, player3]
turn_data = []

turn_num += 1

# main loop
loop do
  # loop for each player
  players.each do |player|
    Write.turn_data(turn_data, turn_num, player.num)
    Write.hand(player.hand)

    # loop for calling cards, break if card not taken
    loop do
      called_card = Read.card(player.hand)
      called_player = players[Read.player(player.num) - 1]
      # check called player for card
      if called_player.check_hand(called_card)
        called_player.take_card(called_card)
        player.add_card(called_card)
        turn_data << {:card_taken => true, :called_player => called_player.num, :calling_player => player.num, :card => called_card}
      else
        turn_data << {:card_taken => false, :called_player => called_player.num, :calling_player => player.num, :card => called_card}
      end
      Write.call(turn_data[-1][:card_taken], called_player.num)
      unless turn_data[-1][:card_taken]
        # draw card
        drawn_card = reserve.draw_card
        player.add_card(drawn_card)
        Write.draw_card(drawn_card)
        # check if drawn card is called card
        break unless drawn_card == Deck.card_id(called_card)
      end
    end
    turn_num += 1
  end
end

# deck is made as a hash/array as below
# [
#   :set_num => ,
#   :set_data => {
#     :set_name => ,
#   :  set_cards => [
#       :set_pos => ,
#       :card_data => {
#         :card_name => ,
#         :card_desc => ,
#       ],
#       ...
#     },
#   },
#   ...
# ]

# i.e.
#   array of sets (with attributes set_num and set_data, comprised of set_name, and set_cards , which in turn is comprised of set_pos, and card_data, which is comprised of card_name, and card_desc)
require './modules/deck'

# class to handle players (mainly turn functions)
class Player
  attr_reader :reserve, :player_num, :wanted_card_id, :called_player, :hand

  # init method, that creates all player attr, and a diminished reserve variable (only used by Game class)
  def initialize(player_num, cards)
    @player_num = player_num
    @hand, @reserve = self.create_hand(cards)
  end

  # method to get a players hand (sorted), and to return a decreased reserve pile
  def create_hand(cards)
    hand = cards.sample(6)
    cards -= hand
    return hand.sort, cards
  end

  # method to get a players inputs
  def player_turn
    puts 'Your cards are'
    @hand.each { |card| print_card(*Deck.card_data(*card), Deck.card_set(*card)) }

    # TODO: find solution that doesn't use instance variables, but allows access from other scopes

    # get and check input for card name
    @wanted_card_id = input_wanted_card()
    # get and check input for player number
    @called_player = input_wanted_player()
  end

  # method to get / check a players wanted card input
  def input_wanted_card
    loop do
      print 'What card do you want (only from sets you have): '
      wanted_card_name = gets.chomp
      # check against sets, and validate input
      if (@hand.collect { |e| e[0] }.include? (Deck.card_id(wanted_card_name)[0])) && !(@hand.include? (Deck.card_id(wanted_card_name)))
        return Deck.card_id(wanted_card_name)
      else
        puts 'Please enter a valid card name...'
      end
    end
  end

  # method to get / check wanted player input
  def input_wanted_player
    loop do
      print 'What player do you call: '
      called_player = gets.chomp.to_i
      if called_player != @player_num && called_player <= 3 && called_player >= 1
        return called_player
      else
        puts 'Please enter a valid player number...'
      end
    end
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

# Handling of Turn Data
# --
# @turn_data instance variable used to specify what occurred during the last turn, and notify other players
# @turn_data = [{:card_taken => $bool$, :called_player => $int$, card => $arr$}, ...]
# card_taken true of player [:called_player] has [:card]
# can check for all cases with these variables
# ie.
# :A p call p[n] - doesn't have card / has card
#                             |          |-> call again >> @turn_data && goto A
#                            \/
#                         end turn
# __thus @turn_array[-1] == false for all end cases__

# class to handle game turns
class Game
  attr_reader :reserve

  def initialize(cards)
    @turn_data = []
    @@reserve = cards
    @player1 = Player.new(1, @@reserve)
    @@reserve = @player1.reserve
    @player2 = Player.new(2, @@reserve)
    @@reserve = @player2.reserve
    @player3 = Player.new(3, @@reserve)
    @@reserve = @player3.reserve
    @players = [@player1, @player2, @player3]
  end

  # method to define standard turn code (handles interaction of player objects)
  def game_turn
    (0..2).each do |n|
      cls
      # notify other players of past turn (using player[n-1] turn_data)
      if @turn_data != []
        @turn_data.each do |card|
          if card[:card_taken]
            puts "Player #{@players[n - 1].player_num} took #{Deck.card_data(*card[:card])[0]} from Player #{card[:called_player]}."
          else
            puts "Player #{@players[n - 1].player_num} asked Player #{card[:called_player]} for #{Deck.card_data(*card[:card])[0]} but was denied."
          end
        end
      end
      @turn_data = []
      print "PLAYER #{n + 1}'s TURN. Press enter to continue..."
      pause
      loop do
        cls
        # call each players turn code
        @players[n].player_turn
        # check cards (must be in Game scope to access all players)
        check_card(@players[n].player_num, @players[n].called_player, @players[n].wanted_card_id)
        # if card not taken, draw a new card
        unless @turn_data[-1][:card_taken]
          draw_card(n)
          break
        end
      end
      p Deck.check_set(@players[n].hand)
      pause
      # TODO: Add check for set, no cards, and win

    end
  end

  # TODO: loop if card_taken == true // DONE

  # method to check if a card is present in a players hand (and to update turn_data)
  def check_card(player_num, called_player_num, card_id)
    card_taken =
      if @players[called_player_num - 1].hand.include? (card_id)
        @players[called_player_num - 1].take_card(card_id)
        @players[player_num - 1].add_card(card_id)
        print "Player #{called_player_num} had the card"
        true
      else
        puts "Player #{called_player_num} didn't have the card..."
        false
      end
    @turn_data << {:card_taken => card_taken, :called_player => called_player_num, :card => card_id}
    pause
  end

  # method to draw a random card, and decrease reserve pile
  def draw_card(player_index)
    added_card = @@reserve.sample
    @players[player_index].add_card(added_card)
    @@reserve -= [added_card]
    print "#{Deck.card_data(*added_card)[0]} was drawn."
    pause
  end
end

# independent functions
def pause
  system('pause>nul')
end

def cls
  system('cls')
end

# TODO: fix display of cards (eliminate hash - error possibly stemming from Deck::card_set)

# game functions
# function that prints cards data
def print_card(card_name, card_desc, set_name, set_num, set_pos, card_set)
  puts '----------------'
  puts card_set
  #card_set.each { |card| puts " #{card}" }
  puts "#{set_name.upcase}    #{set_num}-#{set_pos}"
  puts "  #{card_name.upcase}"
  puts "(#{card_desc})"
  puts '----------------'
end

# single line card print for debugging
def quick_print_card(card_name, _card_desc, _set_name, _set_num, _set_pos, _card_set)
  puts card_name
end


# array of acceptable card ids (static list), eg. [[1, "A"], [1, "B"],...]
cards = Deck.compile_id_array

# main loop
turn = 0
loop do
  if turn == 0
    # init game object
    game = Game.new(cards)
    game.game_turn
    # TODO: implement better reserve pile handling // wontfix

    turn += 1
  end
  game.game_turn
end
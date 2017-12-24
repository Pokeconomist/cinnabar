# TODO: see .\cinnabar.rb:99 & .\cinnabar.rb:100 2017-12-22 //DONE
# TODO: add player inputs / calls 2017-12-19 //DONE
# TODO: complete player / reserve classes 2017-12-18 //PROGRESS
# TODO: move large descriptive comments to readme files 2017-12-24
#
# Title; Cinnabar
# Author; Soda Adlmayer
# Date of Version; 2017-12-24

require '.\modules\deck.rb'
require '.\modules\write.rb'
require '.\modules\read.rb'

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
  def check_card(card_id)
    return @hand.include?(card_id)
  end

  # method to check hand for complete sets, and return them
  def check_set
    complete_sets = []
    # iterate over unique sets
    @hand.collect { |card| card[0] }.uniq.each do |set|
      # count number of cards from set, and compare to set length
      if @hand.collect { |card| card[0] }.count(set) == Deck.set_data[2]
        complete_sets << Deck.set_data[0]
      end
    end
    complete_sets
  end

  # method to check for title card
  def check_cinnabar
    return @hand.include?([1, "A"])
  end

  # method to check for set 1 cards, and return them
  def check_set_one
    return @hand.select { |card| card[0] == 1 }
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
# turn_data variable used to specify what occurred during the last turn, and notify other players, and is reset each turn
#
# turn_data = [{:card_taken => $bool$, :called_player_num => $int$, :calling_player_num => $int$, :card => $arr$}, ...]
#
# card_taken = true if player [:called_player_num] has [:card]
# can check for all cases with these variables
# ie.
# :A p call p[n] - (doesn't have card / has card)
#                             |          |-> call again >> turn_data && goto A
#                            \/
#                         end turn
#
# __thus turn_data[-1][:card_taken] == false for all end cases__

# Handling of completed set data
# --
# completed_sets variable used to record completed sets, and to notify other players
#
# completed_sets = [{:set_num => $int$, :player_num => $int$}, ...]

# initialise game objects
reserve = Reserve.new
player1 = Player.new(1, reserve.create_hand)
player2 = Player.new(2, reserve.create_hand)
player3 = Player.new(3, reserve.create_hand)

players = [player1, player2, player3]
turn_data = []
turn_num = 1
crown_active = false

# main loop
loop do

  # loop for each player
  players.each do |player|
    Write.turn_data(turn_data, turn_num, player.num)

    # TODO: add write completed sets data 2017-12-24

    # loop for calling cards, break if card not taken
    loop do
      Write.hand(player.hand)

      # get called card and player inputs
      called_card = Read.card(player.hand)
      called_player = players[Read.player(player.num) - 1]
      # check called player for card
      if called_player.check_card(called_card)
        called_player.take_card(called_card)
        player.add_card(called_card)
        card_taken = true
      else
        card_taken = false
      end
      turn_data << {:card_taken => card_taken, :called_player_num => called_player.num, :calling_player_num => player.num, :card => called_card}
      Write.call(card_taken, called_player.num)
      # turn finalisation (if card not taken)
      unless turn_data[-1][:card_taken]
        # draw card
        drawn_card = reserve.draw_card
        player.add_card(drawn_card)
        Write.draw(drawn_card)
        # check if drawn card is called card
        break unless drawn_card == Deck.card_id(called_card)
      end
    end
    # check for title card
    if player.check_cinnabar || crown_active
      crown_active = Read.cinnabar_prompt
      crown_player = player.num
      # take all current set one cards
      (players.reject { |p| p == player }).each do |called_player|
        called_player.check_set_one.each do |card|
          called_player.take_card(card)
          player.add_card(card)
          turn_data << {:card_taken => true, :called_player => called_player.num, :calling_player => player.num, :card => card}
        end
      end
    end

    # TODO: finish set checking methods, i.e. player prompt 2017-12-24
    # TODO: add crown set functionality 2017-12-24

    # check for complete sets (includes using crown set)
    unless player.check_sets.empty?
      player.check_sets.each do |completed_set|
        Read.set

    turn_num += 1
  end
end

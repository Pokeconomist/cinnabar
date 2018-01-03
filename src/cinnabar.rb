# TODO: see .\cinnabar.rb:99 & .\cinnabar.rb:100 2017-12-22 //DONE
# TODO: add player inputs / calls 2017-12-19 //DONE
# TODO: complete player / reserve classes 2017-12-18 //PROGRESS
# TODO: move large descriptive comments to readme files 2017-12-24

# CHRISTMAS UPDATE v1.0
#    *
#   /o\   MERRY
#  /o  \    CHRISTMAS
# /   o \       2017
#   ||

# Title; Cinnabar
# Author; Soda Adlmayer
# Date of Version; 2017-12-25

require_relative '.\modules\deck'
require_relative '.\modules\write'
require_relative '.\modules\read'

# class containing individual player data
class Player
  attr_reader :hand, :num

  # create player objects, drawing six cards for hand (stored as id array)
  def initialize(num, hand)
    @hand = hand
    @num = num
  end

  # method to give card
  def add_card(card_id)
    @hand += [card_id]
    # remove nil elements (from empty reserve) and sort
    @hand.sort!.compact!
  end

  # method to take card
  def take_card(card_id)
    @hand -= [card_id]
    # remove nil elements (from empty reserve) and sort
    @hand.sort!.compact!
  end

  # method to remove all the cards of a set from hand
  def take_set(set_num)
    @hand -= @hand.select { |card| card[0] == set_num }
  end

  # method to remove all the cards of a set and specified crown set cards from hand
  def take_crown_set(set_num, *crown_set_cards)
    @hand -= @hand.select { |card| card[0] == set_num }
    @hand -= crown_set_cards
  end

  # HAND CHECK METHODS

  # method to check hand for card
  def check_card(card_id)
    return @hand.include?(card_id)
  end

  # method to check hand for complete sets, and return them
  def check_sets
    complete_sets = []
    # iterate over unique sets
    @hand.collect { |card| card[0] }.uniq.each do |set_num|
      # count number of cards from unique sets, and compare to set length
      if @hand.collect { |card| card[0] }.count(set_num) >= Deck.set_data(set_num)[2]
        complete_sets << set_num
      end
    end
    return complete_sets
  end

  # TODO: fix delete return (i.e. ["a", "b", "c"].delete("a") #=> "a" not ["b", "c"]) 2017-12-26

  # method to check hand for complete sets including crown set cards, and return them
  def check_crown_sets
    complete_crown_sets = []
    # iterate over unique sets, save the crown set
    @hand.collect { |card| card[0] }.uniq.delete(4).each do |set_num|
      # count number of cards from unique sets and crown set, and compare to set length, and to return needed crown set cards
      if @hand.collect { |card| card[0] }.count { |n| n == set_num || n == 4 } >= Deck.set_data(set_num)[2]
        # find number of needed crown cards
        num_crown_cards = Deck.set_data(set_num)[2] - @hand.collect { |card| card[0] }.count { |n| n == set_num }
        # find needed crown set cards
        complete_crown_sets << [set_num, @hand.collect { |card| card[0] == 4 }.first(num_crown_cards)]
      end
    end
    return complete_crown_sets
  end

  # method to check for title card
  def check_cinnabar
    return @hand.include?([1, "A"])
  end

  # method to check for set one cards, and return them
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

  # method to return and reduce the reserve by a random card (will return nil for empty reserve)
  def draw_card
    card = @reserve.sample
    @reserve -= [card]
    return card
  end

  # method to create hand
  def create_hand
    hand = []
    6.times { hand << draw_card }
    return hand.sort
  end
end

# initialise game objects
reserve = Reserve.new
player1 = Player.new(1, reserve.create_hand)
player2 = Player.new(2, reserve.create_hand)
player3 = Player.new(3, reserve.create_hand)

players = [player1, player2, player3]
turn_data = []
turn_num = 1
complete_sets = []
title_active = false

# main loop
loop do
  # reset turn data
  # turn_data = [] INCLUSION UNCERTAIN

  # loop for each player
  players.each do |player|
    Write.game_data(turn_data, turn_num, complete_sets, player.num)
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
      # TODO: fix break when drawn_card == called_card 2017-12-25
      # turn finalisation (if card not taken)
      unless turn_data[-1][:card_taken]
        # draw card
        drawn_card = reserve.draw_card
        player.add_card(drawn_card)
        Write.draw(drawn_card)
        # check if drawn card is called card
        break unless drawn_card == called_card
      end
    end

    # TODO: check for set one cards every turn after play 2017-12-25 (merry christmas)

    # check for title card
    if player.check_cinnabar
      title_active = Read.cinnabar_prompt
      # check if cinnabar has been played
      if title_active
        # take all current set one cards
        (players.reject { |p| p == player }).each do |called_player|
          called_player.check_set_one.each do |card|
            called_player.take_card(card)
            player.add_card(card)
            turn_data << {:card_taken => true, :called_player_num => called_player.num, :calling_player_num => player.num, :card => card}
          end
        end
      end
    end

    # TODO: finish set checking methods, i.e. player prompt 2017-12-24 //PROGRESS
    # TODO: add crown set functionality 2017-12-24 //PROGRESS
    # TODO: recognise completed set as using crown set and remove other cards from play

    # check for complete set
    unless player.check_sets.empty?
      player.check_sets.each do |complete_set_num|
        play_set = Read.set_prompt(complete_set_num)
        if play_set
          player.take_set(complete_set_num)
          complete_sets << {:set_num => complete_set_num, :player_num => player.num, :crown_cards => []}
        end
      end
    end
    # check for complete sets using crown set
    unless player.check_crown_sets.empty?
      player.check_crown_sets.each do |complete_set_data|
        play_set = Read.crown_set_prompt(complete_set_data)
        if play_set
          player.take_crown_set(*complete_set_data)
          complete_sets << {:set_num => complete_set_data[0], :player_num => player.num, :crown_cards => complete_set_data[1]}
        end
      end
    end

    turn_num += 1
  end
end
# TODO: add all input methods 2017-12-22 // PROGRESS

# module containing all input methods
module Read
  extend self

  # method to setup game variables
  def game_setup
    print "Number of players needed (will default to three for invalid input): "
    num_players = gets.chomp.to_i
    return num_players > 3 ? num_players : 3
  end

  # method to get called card input
  def card(hand)
    loop do
      print "What card do you want (only from sets you have): "
      wanted_card_name = gets.chomp
      # check against sets, and validate input (i.e. wanted card set in hand, but wanted card is not)
      if (hand.collect { |e| e[0] }.include? (Deck.card_id(wanted_card_name)[0])) && !(hand.include? (Deck.card_id(wanted_card_name)))
        return Deck.card_id(wanted_card_name)
      else
        print "Please enter a valid card name...\n"
      end
    end
  end

  # method to read called player input
  def player(num_players, player_num)
    loop do
      print "What player do you call: "
      called_player = gets.chomp.to_i
      if called_player != player_num && called_player.between?(1, num_players)
        return called_player
      else
        print "Please enter a valid player number...\n"
      end
    end
  end

  # method to read if a player wishes to use cinnabar
  def cinnabar_prompt
    print "Do you wish to use the cinnabar card (y/n): "
    return gets.chr.downcase == 'y' ? true : false
  end

  # method to read if a player wishes to play a complete set
  def set_prompt(set_num)
    print "Do you wish to lay down the #{Deck.set_data(set_num)[1]} set (y/n): "
    return gets.chr.downcase == 'y' ? true : false
  end

  # TODO: add list of crown cards to prompt 2017-12-26 (great day for the race)

  # method to read if a player wished to play a set using a crown set card
  def crown_set_prompt(set_num, crown_set_cards)
    crown_cards = crown_set_cards.collect { |card_id| Deck.card_data(*card_id)[0] }
    print "Do you wish to lay down the #{Deck.set_data(set_num)[1]} set using #{crown_cards.to_list} (y/n): "
    return gets.chr.downcase == 'y' ? true : false
  end
end
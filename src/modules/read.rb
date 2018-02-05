module Cinnabar
  # Namespace containing all input methods.
  module Read
    module_function

    # Read game setup variables.
    # @return [Integer] Number of players
    def game_setup
      print "Number of players wanted (defaults to closest min/max player value): "
      num_players = gets.chomp.to_i
      print "Number of computer players wanted (will be subtracted from number of players, defaults to zero, currently does nothing): "
      num_cpu = gets.chomp.to_i
      num_players = if num_players < Config.min_players
                      Config.min_players
                    elsif num_players > Config.max_players
                      Config.max_players
                    else
                      num_players
                    end
      num_cpu = num_players - num_cpu > 1 ? num_cpu : 0
      return num_players, num_cpu
    end

    # Read and confirm a wanted card name.
    # @param hand [Array] Player's hand
    # @return [Array] Verified card id
    def card(hand)
      loop do
        print "What card do you want (only from sets you have): "
        wanted_card_name = gets.chomp
        # check against sets, and validate input (i.e. wanted card set in hand, but wanted card is not)
        unless Deck.card_id(wanted_card_name).nil?
          if (hand.collect { |e| e[0] }.include? (Deck.card_id(wanted_card_name)[0])) && !(hand.include? (Deck.card_id(wanted_card_name)))
            return Deck.card_id(wanted_card_name)
          end
        else
          print "Please enter a valid card name...\n"
        end
      end
    end

    # Read and confirm a wanted player number.
    # @param num_players [Integer] Amount of game players
    # @param player_num [Integer] Number of calling player
    # @return [Integer] Verified player number
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

    # Prompt to lay down complete set.
    # @return [Boolean]
    def set_prompt(set_num)
      print "Do you wish to lay down the #{Deck.set_data(set_num)[1]} set (y/n): "
      return gets.chr.downcase == 'y' ? true : false
    end
  end
end
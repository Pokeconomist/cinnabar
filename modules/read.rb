# TODO: add all input methods 2017-12-22 //PROGRESS

# module containing all input methods
module Read
  extend self

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
    def player(player_num)
      loop do
        print "What player do you call: "
        called_player = gets.chomp.to_i
        # TODO: add variable player amount functionality
        # check player number valid (i.e. not current player, and within range)
        if called_player != player_num && called_player <= 3 && called_player >= 1
          return called_player
        else
          print "Please enter a valid player number...\n"
        end
      end
    end

    # method to read if a player wishes to use cinnabar
    def cinnabar_prompt
      print "Do you wish to use the cinnabar card (y/n): "
      inp = gets.chr.downcase
      case inp
      when 'y' then true
      when 'n' then false
      end
    end

    # method to read if a player wishes to play a complete set
    def set_prompt(set_num)
      print "Do you wish to lay down #{Deck.set_data[1]} set (y/n): "
      inp = gets.chr.downcase
      case inp
      when 'y' then true
      when 'n' then false
      end
    end
end
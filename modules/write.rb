# TODO: add all output methods 2017-12-22

# module containing all output methods
module Write
  # method to display turn data
  def turn_data(turn_data)
    cls
    print "PREVIOUS TURN: \n"
    unless turn_data == []
      turn_data.each do |card|
        if card[:card_taken]
          puts "Player #{card[:calling_player]} took #{Deck.card_data(*card[:card])[0]} from Player #{card[:called_player]}."
        else
          puts "Player #{card[:calling_player]} asked Player #{card[:called_player]} for #{Deck.card_data(*card[:card])[0]} but was denied."
        end
      end
      pause
    end
  end
  
  # method to display turn info
  def turn_info(player_num)
    cls
    print "PLAYER #{player_num}'s TURN. Press enter to continue..."
    pause
  end
  
  # method to display players hand
  def hand(hand)
    cls
    print "Your cards are: \n"
    hand.each { |card_id| write_card(card_id) }
    pause
  end
  
  # method to display card data
  def card(card_id)
    card_name, card_desc, set_name, set_num, set_pos = Deck.card_data(*card_id)
    print "----------------\n"
    Deck.card_set(*card_id).each { |card| print " #{card}\n" }
    print "#{set_name.upcase}    #{set_num}-#{set_pos}\n"
    print "  #{card_name.upcase}\n"
    print "(#{card_desc})\n"
    print "----------------\n"
  end
end
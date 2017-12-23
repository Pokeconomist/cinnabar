# TODO: add all output methods 2017-12-22

require '.\modules\deck.rb'

# module containing all output methods
module Write
  extend self
  # test method
  def test
    print "WRITE: THIS IS A TEST. THIS SHOULD NOT BE SEEN DURING NORMAL USE.\n"
  end

  # method to display turn data, including turn number, previous turn data, and player number
  def turn_data(turn_data, turn_num, player_num)
    cls
    print "TURN NUMBER #{turn_num}.\n"
    unless turn_data == []
      print "PREVIOUS TURN DATA: \n"
      turn_data.each do |card|
        if card[:card_taken]
          print "Player #{card[:calling_player]} took #{Deck.card_data(*card[:card])[0]} from Player #{card[:called_player]}.\n"
        else
          print "Player #{card[:calling_player]} asked Player #{card[:called_player]} for #{Deck.card_data(*card[:card])[0]} but was denied.\n"
        end
      end
    end
    print "PLAYER #{player_num}'s TURN. Press any key to continue...\n"
    pause
  end

  # method to display players hand
  def hand(hand)
    cls
    print "Your cards are: \n"
    hand.each { |card_id| Write.card(card_id) }
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

  # SYSTEM DISPLAY FUNCTIONS

  def pause
    system 'pause>nul'
  end
  def cls
    system 'cls'
  end
end
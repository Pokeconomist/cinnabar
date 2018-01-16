# TODO: add all output methods 2017-12-22 //PROGRESS
# TODO: see .\cinnabar.rb:129 (Write.completed_set_data) 2017-12-24

# module containing all output methods
module Write
  extend self

  # method to display game set up info
  def game_setup
    cls
    print "----------------\n"
    print "Cinnabar - A Game Of Rocks and Minerals\n"
    print "----------------\n\n"

    print "DISCLAIMER\n"
    print "    Cinnabar (c) 1966, 1972, 1980 is a trademarks of Naturegraph Publishers, Inc.\n"
    print "    No copyright or trademark infringement is intended in using Cinnabar.\n\n"

    print "Welcome to Cinnabar, a digital version of the 1966 card game by Vinson Brown.\n"
    print "Rules can be found in RULES.md, and info can be found in README.md.\n"
    print "Source code can be found at https://www.github.com/Pokeconomist/cinnabar.\n\n"
  end

  # method to display turn data, including turn number, previous turn data, completed sets, and player number
  def game_data(turn_data, turn_num, complete_sets, player_num)
    cls
    # print "$p#{player_num}_t#{turn_num}\n"
    # display completed sets
    unless complete_sets.empty?
      print "\nCOMPLETED SETS:\n\n"
      complete_sets.each do |set|

        # TODO: list crown set cards by name when needed 2017-12-26

        if set[:crown_cards].empty?
          print "    #{Deck.set_data(set[:set_num])[1]}, Player #{set[:player_num]}.\n\n"
        else
          crown_cards = set[:crown_cards].collect { |card_id| Deck.card_data(*card_id)[0]}
          print "    #{Deck.set_data(set[:set_num])[1]}, Player #{set[:player_num]}, using #{crown_cards.to_list}.\n\n"
        end
      end
    end
    # display previous turn data
    unless turn_data.empty?
      print "PREVIOUS TURN DATA:\n\n"
      turn_data.each do |card|
        if card[:card_taken]
          print "    Player #{card[:calling_player_num]} took #{Deck.card_data(*card[:card])[0]} from Player #{card[:called_player_num]}.\n\n"
        else
          print "    Player #{card[:calling_player_num]} asked Player #{card[:called_player_num]} for #{Deck.card_data(*card[:card])[0]} but was denied.\n\n"
        end
      end
    end

    print "----------------\n"
    print "PLAYER #{player_num}'s TURN. Press any key to continue...\n"
    print "----------------\n"
    pause
  end

  # method to display players hand
  def hand(hand)
    cls
    print "Your cards are:\n"
    hand.each { |card_id| Write.card(card_id) }
  end

  # method to display card data
  def card(card_id)
    card_name, card_desc, set_name, set_num, set_pos = Deck.card_data(*card_id)
    print "----------------\n"
    Deck.card_set(*card_id).each { |card| print "  #{card}\n" }
    print "#{set_name.upcase} #{" " * (23 - set_name.length)}#{set_num}-#{set_pos}\n"
    print "    #{card_name.upcase}\n"
    print "(#{card_desc})\n"
    print "----------------\n"
  end

  # method to display success of card / player call
  def call(card_taken, called_player)
    print card_taken ? "Player #{called_player} had the card. " : "Player #{called_player} didn't have the card. "
    print "Press any key to continue...\n"
    pause
  end

  # method to display drawn card info
  def draw(card_id)
    print "#{Deck.card_data(*card_id)[0]} was drawn.\n"
    pause
  end

  # SYSTEM DISPLAY FUNCTIONS (specific to Windows)

  def pause
    system 'pause>nul'
  end
  def cls
    system 'cls'
  end
end
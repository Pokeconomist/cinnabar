# TODO: add all output methods 2017-12-22 //PROGRESS
# TODO: see .\cinnabar.rb:129 (Write.completed_set_data) 2017-12-24

# Namespace containing all output methods.
module Write
  extend self

  # Displays game setup info.
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

  # Displays completed sets.
  # @param complete_sets [Array] Array of currently completed sets and relevant data
  #   i.e.
  #     [
  #       {
  #         set_num =>     1,
  #         player_num =>  1,
  #         crown_cards => [[4,'A']]
  #       },
  #       ...
  #     ]
  def complete_sets(complete_sets)
    cls
    unless complete_sets.empty?
      print "\nCOMPLETED SETS:\n\n"
      complete_sets.each do |set|

        # TODO: list crown set cards by name when needed 2017-12-26 //DONE

        if set[:crown_cards].empty?
          print "    #{Deck.set_data(set[:set_num])[1]}, Player #{set[:player_num]}.\n\n"
        else
          crown_cards = set[:crown_cards].collect { |card_id| Deck.card_data(*card_id)[0]}
          print "    #{Deck.set_data(set[:set_num])[1]}, Player #{set[:player_num]}, using #{crown_cards.to_list}.\n\n"
        end
      end
    end
  end

  # Displays previous turn data.
  # @param turn_data [Array] Previous turn's data
  #   i.e.
  #     [
  #       {
  #         card_taken:         false,
  #         called_player_num:  2,
  #         calling_player_num: 2,
  #         card:               [1, 'A']
  #       },
  #       ...
  #     ]
  def turn_data(turn_data)
    unless turn_data.empty?
      print "\nPREVIOUS TURN DATA:\n\n"
      turn_data.each do |card|
        if card[:card_taken]
          print "    Player #{card[:calling_player_num]} took #{Deck.card_data(*card[:card])[0]} from Player #{card[:called_player_num]}.\n\n"
        else
          print "    Player #{card[:calling_player_num]} asked Player #{card[:called_player_num]} for #{Deck.card_data(*card[:card])[0]} but was denied.\n\n"
        end
      end
    end
  end

  # Interim between player's turns.
  # @param player_num [Integer] Current player number
  def hold_screen(player_num)
    print "----------------\n"
    print "PLAYER #{player_num}'s TURN. Press any key to continue...\n"
    print "----------------\n"
    pause
  end

  # Displays player's hand.
  # @param hand [Array] Player's hand
  def hand(hand)
    cls
    print "Your cards are:\n"
    hand.each { |card_id| Write.card(*card_id) }
  end

  # Displays card data.
  # @param set_num [Integer] Card's set number
  # @param set_pos [Character] Card's set position
  def card(set_num, set_pos)
    card_name, card_desc, set_name, set_num, set_pos = Deck.card_data(set_num, set_pos)
    print "----------------\n"
    Deck.card_set(set_num, set_pos).each { |card| print "  #{card}\n" }
    print "#{set_name.upcase} #{" " * (23 - set_name.length)}#{set_num}-#{set_pos}\n"
    print "    #{card_name.upcase}\n"
    print "(#{card_desc})\n"
    print "----------------\n"
  end

  # Displays success of card and player call.
  # @param card_taken [Boolean] Whether or not a card was taken
  # @param called_player [Integer] Player number from which card was asked
  def call(card_taken, called_player)
    print card_taken ? "Player #{called_player} had the card. " : "Player #{called_player} didn't have the card. "
    print "Press any key to continue...\n"
    pause
  end

  # Displays drawn card info.
  # @param (see #card)
  def draw(set_num, set_pos)
    print "#{Deck.card_data(set_num, set_pos)[0]} was drawn.\n"
    pause
  end

  # Windows specific pause.
  def pause
    system 'pause>nul'
  end

  # Windows specific clear screen.
  def cls
    system 'cls'
  end
end
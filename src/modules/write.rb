# Namespace containing all output methods.
module Write
  include Constants

  module_function

  # Displays game setup info.
  def game_setup
    DiscordIO.putd Constants::SETUP_CHANNEL_ID, "\n\
     Cinnabar - A Game Of Rocks and Minerals\n\
     \n\
         Cinnabar (c) 1966, 1972, 1980 is a trademark of Naturegraph Publishers, Inc.\n\
         No copyright or trademark infringement is intended in using Cinnabar.\n\n\
     Welcome to Cinnabar, a digital version of the 1966 card game by Vinson Brown.\n\
     Rules can be found in RULES.md, and info can be found in README.md.\n\
     Source code can be found at https://www.github.com/Pokeconomist/cinnabar.\n"
  end

  # Displays completed sets.
  # @param complete_sets [Array<Hash>]
  #   Array of currently completed sets and relevant data.
  #   i.e.
  #     [
  #       {
  #         set_num =>     1,
  #         player_num =>  1,
  #       },
  #       ...
  #     ]
  def complete_sets(complete_sets)
    unless complete_sets.empty?
      DiscordIO.putd "\nCOMPLETED SETS:\n\n"
      complete_sets.each { |set| DiscordIO.putd "    #{Deck.set_data(set[:set_num])[1]}, Player #{set[:player_num]}.\n\n" }
    end
  end

  # Displays game win
  # @param player_num [Integer] Current player number
  def win(player_num, complete_sets)
    sets = complete_sets.select { |set| set[:player_num] == player_num }.map { |set| Deck.set_data(set[:set_num])[1] }
    DiscordIO.putd "Player #{player_num} wins, playing #{sets.list}!!!\n"
  end

  # Displays player's hand.
  # @param player [Player] Player object's hand to display
  # @param channel_id [Integer] Channel to target
  def hand(hand, channel_id)
    DiscordIO.putd_embed channel_id, '**Your cards are: **' << hand.map { |card_id| Write.card *card_id }.join
  end

  # Displays card data.
  # @param set_num [Integer] Card's set number
  # @param set_pos [String] Card's set position
  # @return [String] Single line representation of card for discord embed
  def card(set_num, set_pos)
    card_name, card_desc, set_name, set_num, set_pos = Deck.card_data(set_num, set_pos)
    return "```#{Deck.card_set(set_num, set_pos).map { |card| "  #{card}\n" }.join << "#{set_name.upcase} #{" " * (23 - set_name.length)}#{set_num}-#{set_pos}\n    #{card_name.upcase}\n"}```"
  end

  # Displays success of card and player call.
  # @param card_taken [Boolean] Whether or not a card was taken
  # @param called_player [Player] Player from which card was asked
  # @param calling_player [Player] Player asking for card
  def call(card_id, card_taken, called_player, calling_player)
    DiscordIO.putd Constants::CINNABAR_BOT.pm_channel(calling_player.id).id, card_taken ? "#{called_player.name} had the card. " : "#{called_player.name} didn't have the card. "
    DiscordIO.putd card_taken ? "#{calling_player.name} took #{Deck.card_data(*card_id)[0]} from #{called_player.name}" : "#{calling_player.name} asked #{called_player.name} for #{Deck.card_data(*card_id)[0]} but was denied."
  end

  # Displays drawn card info.
  # @param (see #card)
  # @param channel_id [Integer] Channel to target
  def draw(set_num, set_pos, channel_id)
    DiscordIO.putd channel_id, "#{Deck.card_data(set_num, set_pos)[0]} was drawn.\n"
  end
end
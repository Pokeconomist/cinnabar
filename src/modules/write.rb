module Cinnabar
  # Namespace containing all output methods.
  module Write
    include Constants
    module_function
    require '.\src\core_extensions\array\list'

    # Displays game setup info.
    def game_setup
      DiscordIO.putd SETUP_CHANNEL_ID, "\n\
      Cinnabar - A Game Of Rocks and Minerals\n\
      \n\
          Cinnabar (c) 1966, 1972, 1980 is a trademark of Naturegraph Publishers, Inc.\n\
          No copyright or trademark infringement is intended in using Cinnabar.\n\n\
      Welcome to Cinnabar, a digital version of the 1966 card game by Vinson Brown.\n\
      Rules can be found in RULES.md, and info can be found in README.md.\n\
      Source code can be found at https://www.github.com/Pokeconomist/cinnabar.\n"

      DiscordIO.putd SETUP_CHANNEL_ID, "Type `join` to join the game, and `begin` to start the game.\n"
    end

    # Displays turn info.
    # @params players [Player]
    def turn(player)
      DiscordIO.putd "[GAME #{GAME_ID}] #{player.mention}'s turn\n"
    end

    # Displays player's hands.
    # @params players [Array<Player>] Array of player objects
    def hands(players)
      players.each do |player|
        Write.hand player.hand, CINNABAR_BOT.pm_channel(player.id).id
      end
    end

    # Displays completed sets.
    # @param set_num [Integer] Complete sets number
    # @params players [Player]
    def complete_set(set_num, player)
      DiscordIO.putd "[GAME #{GAME_ID}] #{player.mention} played #{Deck.set_data(set_num)[1]}."
    end

    # Displays game win
    # @param player_num [Integer] Current player number
    def win(player_num, complete_sets)
      sets = complete_sets.select { |set| set[:player_num] == player_num }.map { |set| Deck.set_data(set[:set_num])[1] }
      DiscordIO.putd "Player #{player_num} wins, playing #{sets.to_list}!!!\n"
    end

    # Displays player's hand.
    # @param hand [Array] Player object's hand to display
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
      DiscordIO.putd CINNABAR_BOT.pm_channel(calling_player.id).id, card_taken ? "#{called_player.name} had the card. " : "#{called_player.name} didn't have the card. "
      DiscordIO.putd card_taken ? "[GAME #{GAME_ID}] #{calling_player.name} took #{Deck.card_data(*card_id)[0]} from #{called_player.mention}" : "[GAME #{GAME_ID}] #{calling_player.name} asked #{called_player.mention} for #{Deck.card_data(*card_id)[0]} but was denied."
    end

    # Displays drawn card info.
    # @param (see #card)
    # @param channel_id [Integer] Channel to target
    def draw(set_num, set_pos, channel_id)
      DiscordIO.putd channel_id, "#{Deck.card_data(set_num, set_pos)[0]} was drawn.\n"
    end
  end
end
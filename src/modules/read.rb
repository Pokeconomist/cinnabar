module Cinnabar
  # Namespace containing all input methods.
  module Read
    module_function
    include Constants
    require '.\src\core_extensions\string\titleise'

    # Read and confirm a wanted card name.
    # @param hand [Array] Player's hand
    # @param player_id [Integer] Player id to target
    # @return [Array] Verified card id
    def card(hand, player_id)
      channel_id = CINNABAR_BOT.pm_channel(player_id).id
      loop do
        DiscordIO.putd channel_id, "What card do you want (only from sets you have): "
        wanted_card_name = DiscordIO.getd(player_id).chomp.titleise
        # check against sets, and validate input (i.e. wanted card set in hand, but wanted card is not)
        unless Deck.card_id(wanted_card_name).nil?
          if (hand.collect { |e| e[0] }.include? (Deck.card_id(wanted_card_name)[0])) && !(hand.include? (Deck.card_id(wanted_card_name)))
            return Deck.card_id(wanted_card_name)
          else
            DiscordIO.putd channel_id, "Please enter a valid card name...\n"
          end
        else
          DiscordIO.putd channel_id, "Please enter a valid card name...\n"
        end
      end
    end

    # Read and confirm a wanted player number.
    # @param num_players [Integer] Amount of game players
    # @param player_num [Integer] Number of calling player
    # @param player_id [Integer] Player id to target
    # @return [Integer] Verified player number
    def player(num_players, player_num, player_id)
      channel_id = CINNABAR_BOT.pm_channel(player_id).id
      loop do
        DiscordIO.putd channel_id, "What player do you call: "
        called_player = DiscordIO.getd(player_id).chomp.to_i
        if called_player != player_num && called_player.between?(1, num_players)
          return called_player
        else
          DiscordIO.putd channel_id, "Please enter a valid player number...\n"
        end
      end
    end

    # Prompt to lay down complete set.
    # @param player_id [Integer] Player id to target
    # @param channel_id [Integer] Channel id to target, defaults to player_id's PM channel
    # @return [Boolean]
    def set_prompt(set_num, player_id)
      channel_id = CINNABAR_BOT.pm_channel(player_id).id
      DiscordIO.putd channel_id, "Do you wish to lay down the #{Deck.set_data(set_num)[1]} set (y/n): "
      return DiscordIO.getd(player_id).chr.downcase == 'y' ? true : false
    end
  end
end
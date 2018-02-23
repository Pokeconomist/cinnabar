module Cinnabar
  module Commands
    # Initialises game
    module Init
      include Constants
      extend Discordrb::Commands::CommandContainer
      command(:init, description: 'Initialise a game',
                     in: SETUP_CHANNEL_ID,
                     usage: 'init') do |init|
        Write.game_setup
        player_ids = []
        CINNABAR_BOT.message(in: SETUP_CHANNEL_ID, content: 'join') do |message|
          player_ids << message.user.id
          DiscordIO.putd SETUP_CHANNEL_ID, "#{message.user.mention} joined."
        end
        CINNABAR_BOT.message(from: init.user, in: SETUP_CHANNEL_ID, content: 'begin') do |message|
          DiscordIO.putd SETUP_CHANNEL_ID, "Game begun with #{player_ids.uniq.map { |e| CINNABAR_BOT.user(e).mention }.to_list}"
          Cinnabar.main player_ids.uniq
        end
        nil
      end
    end
  end
end
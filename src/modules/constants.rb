module Cinnabar
  # Module containing constant values.
  module Constants
    # Id of main channel.
    MAIN_CHANNEL_ID = Config.main_channel

    # Id of setup channel
    SETUP_CHANNEL_ID = Config.setup_channel

    # Cinnabar bot object.
    CINNABAR_BOT = Discordrb::Commands::CommandBot.new(Config.bot)

    # Game number (random)
    GAME_ID = rand(0..2**16)
  end
end
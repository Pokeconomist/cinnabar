# Module containing constant values.
module Constants
  # Id of main channel.
  CINNABAR_CHANNEL_ID = 395_184_040_757_428_234.freeze

  # Id of setup channel
  SETUP_CHANNEL_ID = 397_599_410_919_440_387.freeze

  # Cinnabar bot object.
  CINNABAR_BOT = Discordrb::Commands::CommandBot.new(
    token: 'Mzk1MDkxMjMzNTM5NzUxOTQ3.DSuW0A.gVOnFQyT7ahaA_1-hFtj3gZRTig',
    client_id: 395091233539751947,
    prefix: '$'
  )
end
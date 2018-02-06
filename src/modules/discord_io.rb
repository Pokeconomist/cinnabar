module Cinnabar
  # Module containing Discord IO methods
  module DiscordIO
    include Constants
    module_function
    require '.\src\core_extensions\array\list'

    # Reads input from discord, and blocks other scripts from running.
    # @param player_id [Integer] User id to target
    # @param channel_id [Integer] Channel id to target, defaults to PM channel
    # @return [String] Message content
    def getd(player_id, channel_id = CINNABAR_BOT.pm_channel(player_id).id)
      content = ''
      begin
        CINNABAR_BOT.user(player_id).await(:getd, in: channel_id) do |message|
          content = message.content
        end
      end until !content.empty?
      return content
    end

    # Writes output to discord.
    # @param channel_id [Integer] Channel id to target, defaults to main channel
    # @param content [String] Content to pm
    # @return [nil]
    def putd(channel_id = MAIN_CHANNEL_ID, content)
      CINNABAR_BOT.send_message channel_id, content
      return nil
    end

    # Write embed to discord.
    # @param [see #putd]
    # @return [nil]
    def putd_embed(channel_id = MAIN_CHANNEL_ID, content)
      CINNABAR_BOT.channel(channel_id).send_embed do |embed|
        embed.colour = 0x701615
        embed.description = content
      end
      return nil
    end

    # Reads player ids from discord, and blocks other scripts from running.
    # @return [Array<Integer>] Array of user ids
    def getd_ids
      player_ids = []
      CINNABAR_BOT.message(in: SETUP_CHANNEL_ID, content: 'join') do |message|
        player_ids << message.user.id
        putd SETUP_CHANNEL_ID, "#{message.user.mention} joined."
        next
      end
      CINNABAR_BOT.message(in: SETUP_CHANNEL_ID, content: 'begin') do |message|
        player_ids << message.user.id
        putd SETUP_CHANNEL_ID, "Game begun with #{player_ids.uniq.map { |e| CINNABAR_BOT.user(e).mention }.to_list}"
        Cinnabar.main player_ids.uniq
      end
    end
  end
end
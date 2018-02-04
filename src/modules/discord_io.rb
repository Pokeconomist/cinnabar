# Module containing Discord IO methods
module DiscordIO
  include Constants
  # Reads input from discord, and blocks other scripts from running.
  # @param player_id [Integer] User id to target
  # @param channel_id [Integer] Channel id to target, defaults to PM channel
  # @return [String] Message content
  def self.getd(player_id, channel_id = CINNABAR_BOT.pm_channel(player_id).id)
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
  def self.putd(channel_id = CINNABAR_CHANNEL_ID, content)
    CINNABAR_BOT.send_message channel_id, content
    return nil
  end

  #Write embed to discord
  # @param [see #putd]
  # @return [nil]
  def self.putd_embed(channel_id = CINNABAR_CHANNEL_ID, content)
    CINNABAR_BOT.channel(channel_id).send_embed do |embed|
      embed.colour = 0x701615
      embed.description = content
    end
    return nil
  end
  CINNABAR_BOT.run :async
end
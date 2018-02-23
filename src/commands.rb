module Cinnabar
  # Module for commands.
  module Commands
    include Constants
    Dir.glob('./src/commands/*.rb').each { |file| require file }

    @commands = [
      Init,
      Ping,
      Delete
    ]

    def self.include!
      @commands.each do |command|
        CINNABAR_BOT.include! command
      end
    end
  end
end
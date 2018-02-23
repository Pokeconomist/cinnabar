module Cinnabar
  module Commands
    # Gets response time.
    module Ping
      extend Discordrb::Commands::CommandContainer
      command(:ping, description: 'Get ping in milliseconds.',
                     usage: 'Ping!') do |ping|
        "Reply from server: #{((Time.now - ping.timestamp) * 1000).to_i} ms."
      end
    end
  end
end
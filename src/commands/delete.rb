module Cinnabar
  module Commands
    # Deletes specified amount of messages from the channel.
    module Delete
      extend Discordrb::Commands::CommandContainer
      command(:delete, description: 'Deletes messages in this channel, including the command call.',
                       min_args: 1,
                       required_permissions: [:manage_messages],
                       usage: 'delete <amount >= 1>') do |event, amount|
        if event.bot.profile.on(event.server).permission?(:manage_messages, event.channel)
          amount = amount.to_i + 1
          next "ArgumentError" if amount < 2
          if amount % 100 < 2
            event.channel.prune(2)
            amount -= 2
          end
          while amount > 100
            event.channel.prune(100)
            amount -= 100
          end
          event.channel.prune(amount) if amount >= 2
          nil
        end
      end
    end
  end
end
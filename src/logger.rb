module Cinnabar
  # Log handler.
  module Logger
    module_function

    # Log file.
    LOG = File.new('/data/cinnabar.log', 'w')

    # Writes to log.
    # @param player [Player] Player object
    # @param turn_num [Integer]
    # @param turn_data [Array<Hash>]
    #   Previous turn's data
    #   i.e.
    #     [
    #       {
    #         card_taken:         false,
    #         called_player_num:  2,
    #         calling_player_num: 2,
    #         card:               [1, 'A']
    #       },
    #       ...
    #     ]
    # @param drawn_card [Array] Drawn card id
    def log(player, turn_num, turn_data, drawn_card)
      hand = player.hand.map { |e| e.join }.join('_')
      turn_data = turn_data.map { |e| "#{e[:called_player_num]}_q#{e[:card].join}_#{e[:card_taken] ? 'o' : 'x'}" }.join('|')
      "[DATA @ #{Time.now}] p#{player.num}|t#{turn_num}|h#{hand}|#{turn_data}|d#{drawn_card.join}"
    end
  end
end

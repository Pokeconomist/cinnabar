# Container of game methods
module Game
  include Constants

  module_function

  # Obtains players input of called card and player, and acts on inputs.
  # @param (see #set_check)
  # @param called_card [Array(Integer, String)] Card id of called card
  # @param called_player [Player] Called player object
  def call_card(player, called_card, called_player)
    if called_player.check_card(called_card)
      called_player.take_card(called_card)
      player.add_card(called_card)
      card_taken = true
    else
      card_taken = false
    end
    Write.call(called_card, card_taken, called_player, player)
  end

  # Checks for complete sets in a players hand, and plays them on player prompt.
  # @param player [Player] Calling player object
  # @return [Hash] Set data hash
  def set_check(player)
    unless player.check_sets.empty?
      player.check_sets.each do |set_num|
        if Read.set_prompt(set_num, player.id)
          player.take_set(set_num)
          return {
            set_num:     set_num,
            player_num:  player.num,
            crown_cards: []
          }
        end
      end
    end
  end

  #TODO: allow for dynamic number of sets

  # Checks if a games has been completed, i.e. all sets played
  # @param complete_sets [Array<Hash>]
  #   Array of currently completed sets and relevant data.
  #   i.e.
  #     [
  #       {
  #         set_num =>     1,
  #         player_num =>  1,
  #       },
  #       ...
  #     ]
  def win_check(complete_sets)
    return complete_sets.length == 12
  end

  # Determines winner of game
  # @param players [Array<Player>] Array of game players
  # @param complete_sets [Array<Hash>]
  #   Array of currently completed sets and relevant data.
  #   i.e.
  #     [
  #       {
  #         set_num =>     1,
  #         player_num =>  1,
  #       },
  #       ...
  #     ]
  def win(players, complete_sets)
    set_count = []
    players.each do |player|
      set_count << {
        player_num: player.num,
        num_sets:   complete_sets.count { |set| set[:player_num] == player.num }
      }
    end
    winning_player_num = set_count.max { |a, b| a[:num_sets] <=> b[:num_sets] }[:player_num] # TODO allow for ties 2018-01-30
    Write.win(winning_player_num)
  end
end
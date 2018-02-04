# TODO: add 'emulated' card calls for cinnabar plays 2018-01-14 //DONE
# TODO: recognise completed set as using crown set and remove other cards from play 2018-01-17

# CHRISTMAS UPDATE v1.0
#    *
#   /o\   MERRY
#  /o  \    CHRISTMAS
# /   o \       2017
#   ||

require 'discordrb'

require_relative '.\modules\constants'
require_relative '.\modules\deck'
require_relative '.\modules\discord_io'
require_relative '.\modules\game'
require_relative '.\modules\read'
require_relative '.\modules\write'

require_relative '.\classes\player\player'
require_relative '.\classes\player\computer_player'
require_relative '.\classes\reserve\reserve'

require_relative '.\core_extensions\array\list'
require_relative '.\core_extensions\string\titleise'

module Cinnabar
  include Constants

  Write.game_setup
  player_ids = [301_984_303_250_669_568, 239_142_167_698_866_177]#, 254_904_587_557_797_888] #TODO: replace with actual method of getting ids
  Read.game_setup(player_ids[0])

  num_players = player_ids.length

  reserve = Reserve.new
  players = Array.new(num_players) { |i| Player.new(i + 1, reserve.create_hand, player_ids[i]) }

  turn_num = 1
  complete_sets = []

  loop do
    players.each do |player|
      Write.complete_sets(complete_sets)
      if Game.win_check(complete_sets)
        Game.win(players, complete_sets)
      else
        # loop for calling cards, break if card not taken
        loop do
          Write.hand player.hand, CINNABAR_BOT.pm_channel(player.id).id
          Game.call_card(player, Read.card(player.hand, player.id), players[Read.player(num_players, player.num, player.id) - 1])
          unless turn_data[-1][:card_taken]
            drawn_card = reserve.draw_card
            player.add_card(drawn_card)
            Write.draw(*drawn_card, CINNABAR_BOT.pm_channel(player.id).id)
            break unless drawn_card == turn_data[-1][:card]
          end
        end
        complete_sets << Game.set_check(player)
        complete_sets.compact!
        turn_num += 1
      end
    end
  end
end
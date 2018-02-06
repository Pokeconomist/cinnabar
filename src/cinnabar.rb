# TODO: add 'emulated' card calls for cinnabar plays 2018-01-14 //DONE
# TODO: recognise completed set as using crown set and remove other cards from play 2018-01-17

# CHRISTMAS UPDATE v1.0
#    *
#   /o\   MERRY
#  /o  \    CHRISTMAS
# /   o \       2017
#   ||

require 'bundler/setup'

Bundler.require(:default)

module Cinnabar
  require '.\src\config'
  Dir.glob("./src/modules/*.rb").each { |file| require file }
  Dir.glob("./src/classes/**/*.rb").each { |file| require file }
  
  include Constants

  Write.game_setup
  Read.game_setup

  module_function
  def main(player_ids)
    num_players = player_ids.length

    reserve = Reserve.new
    players = Array.new(num_players) { |i| Player.new(i + 1, reserve.create_hand, player_ids[i]) }

    turn_num = 1
    complete_sets = []

    loop do
      Write.hands(players)
      players.each do |player|
        Write.complete_sets(complete_sets)
        if Game.win_check(complete_sets, turn_num)
          Game.win(players, complete_sets)
        else
          loop do
            card_taken, called_card = Game.call_card(player, Read.card(player.hand, player.id), players[Read.player(num_players, player.num, player.id) - 1])
            unless card_taken
              drawn_card = reserve.draw_card
              player.add_card(drawn_card)
              Write.draw(*drawn_card, CINNABAR_BOT.pm_channel(player.id).id)
              break unless drawn_card == called_card
            end
          end
          complete_sets << Game.set_check(player)
          complete_sets.compact!
        end
      end
      turn_num += 1
    end
  end

  CINNABAR_BOT.run
end
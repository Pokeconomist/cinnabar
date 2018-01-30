# TODO: add 'emulated' card calls for cinnabar plays 2018-01-14 //DONE
# TODO: recognise completed set as using crown set and remove other cards from play 2018-01-17

# CHRISTMAS UPDATE v1.0
#    *
#   /o\   MERRY
#  /o  \    CHRISTMAS
# /   o \       2017
#   ||

require_relative '.\modules\deck'
require_relative '.\modules\write'
require_relative '.\modules\read'
require_relative '.\modules\game'

require_relative '.\classes\player'
require_relative '.\classes\reserve'

require_relative '.\core_extensions\array\list'
require_relative '.\core_extensions\string\titleise'

Write.game_setup
num_players = Read.game_setup

reserve = Reserve.new
players = Array.new(num_players) { |i| Player.new(i + 1, reserve.create_hand) }

turn_num = 1
turn_data = []
complete_sets = []
title_played = false

loop do
  players.each do |player|
    Write.complete_sets(complete_sets)
    Write.turn_data(turn_data)
    Write.hold_screen(player.num)
    # loop for calling cards, break if card not taken
    loop do
      Write.hand(player.hand)
      turn_data << Game.call_card(player, Read.card(player.hand), players[Read.player(num_players, player.num) - 1])
      unless turn_data[-1][:card_taken]
        drawn_card = reserve.draw_card
        p drawn_card
        player.add_card(drawn_card)
        Write.draw(*drawn_card)
        break unless drawn_card == turn_data[-1][:card]
      end
    end

    # TODO: add escape ability to Game checks 2018-01-19

    turn_data << Game.title_check(player, players) unless title_played
    complete_sets << Game.set_check(player)
    complete_sets << Game.crown_set_check(player)

    turn_num += 1
  end
end
# TODO: add 'emulated' card calls for cinnabar plays 2018-01-14 //DONE
# TODO: recognise completed set as using crown set and remove other cards from play 2018-01-17

# CHRISTMAS UPDATE v1.0
#    *
#   /o\   MERRY
#  /o  \    CHRISTMAS
# /   o \       2017
#   ||

# Main module.
module Cinnabar
  require '.\src\config'
  require '.\src\logger'

  Dir.glob('./src/classes/**/*.rb').each { |file| require file }
  Dir.glob('./src/modules/*.rb').each { |file| require file }

  Write.game_setup
  num_players, num_cpu = Read.game_setup

  reserve = Reserve.new
  players = Array.new(num_players) { |i| Player.new(i + 1, reserve.create_hand) }

  turn_num = 1
  turn_data = []
  complete_sets = []

  loop do
    players.each do |player|
      Write.complete_sets(complete_sets)
      Write.turn_data(turn_data)
      Write.hold_screen(player.num)
      if Game.win_check(complete_sets, turn_num)
        Game.win(players, complete_sets)
      else
        while true
          Write.hand(player.hand)
          turn_data << Game.call_card(player, Read.card(player.hand), players[Read.player(num_players, player.num) - 1])
          unless turn_data[-1][:card_taken]
            drawn_card = reserve.draw_card
            player.add_card(drawn_card)
            Write.draw(*drawn_card)
            break unless drawn_card == turn_data[-1][:card]
          end
        end
        complete_sets << Game.set_check(player)
        complete_sets.compact!
      end
      Logger.log player, turn_num, turn_data, drawn_card
    end    
    turn_num += 1
  end
end
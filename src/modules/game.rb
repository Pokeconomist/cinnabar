# Container of game methods
module Game
  extend self

  # Obtains players input of called card and player, and acts on inputs.
  # @param (see #set_check)
  # @param called_card [Array(Integer, String)] Card id of called card
  # @param [Player] Called player object
  # @return [Hash(Boolean, Integer, Integer, Array<Array(Integer, String)>)] Turn data hash
  def call_card(player, called_card, called_player)
    if called_player.check_card(called_card)
      called_player.take_card(called_card)
      player.add_card(called_card)
      card_taken = true
    else
      card_taken = false
    end
    Write.call(card_taken, called_player.num)
    return {
      card_taken:         card_taken,
      called_player_num:  called_player.num,
      calling_player_num: player.num,
      card:               called_card
    }  
  end

  # Checks for cinnabar card if not already used (determined when called),
  # and takes all set one cards from all players.
  #
  # Essentially is #call_card method wrapped in a prompt.
  # @param (see #set_check)
  # @param players [Array<Player>] Array of game players
  # @return (see #call_card)
  def title_check(player, players)
    if player.check_title 
      if Read.title_prompt
        (players.reject { |p| p == player }).each do |called_player|
          called_player.check_title_set.each do |card|
            return call_card(player, card, called_player)
          end
        end
      end
    end
  end

  # Checks for complete sets in a players hand, and plays them on player prompt.
  # @param player [Player] Calling player object
  # @return [Hash(Integer, Integer, Array<Array(Integer, String)>)] Set data hash
  def set_check(player)
    unless player.check_sets.empty?
      player.check_sets.each do |set_num|
        if Read.set_prompt(set_num)
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

  # Checks for sets completable using crown set cards.
  #
  # Player#check_crown_sets method will return one complete set at a time,
  # to allow for mid iteration updates.
  def crown_set_check(player)
    unless player.check_crown_sets.empty?
      player.check_crown_sets[0]
      
    end
    
  end
end

require 'json'

# module handling creation and interaction with deck data
module Deck
  extend self

  # DECK CONSTRUCTION

  # get hash from json files, and convert keys to symbols (n.b. JSON files contain expansion information not yet used)
  CARDS = JSON.parse(File.read('.\data\cards.json'), :symbolize_names => true)[:cards]
  SETS = JSON.parse(File.read('.\data\sets.json'), :symbolize_names => true)[:sets]

  DECK = []
  # iterate over sets and select cards from that set, and compile to deck hash
  SETS.each do |set|
    DECK << {
      :set_num => set[:setNumber], :set_data => {
        :set_name => set[:setName], :set_len =>  set[:setLength], :set_cards => (
          # collect array of cards from specific set, and compile to deck hash
          CARDS.select { |card| card[:setNumber] == set[:setNumber] }.collect do |card|
            {
              :set_pos => card[:cardPosition], :card_data => {
                :card_name => card[:cardName], :card_desc => card[:cardDescription]
              }
            }
          end
        )
      }
    }
  end

  # method to create simplifies deck array (comprised of just card ids).
  def id_array
    id_array = []
    DECK.each do |set|
      set[:set_data][:set_cards].each do |card|
        id_array << [set[:set_num], card[:set_pos]]
      end
    end
    return id_array
  end

  # DECK ACCESS METHODS

  # method to return array of card data from id
  def card_data(set_num, set_pos)
    DECK.each do |set|
      # skip iteration unless desired set number
      next unless set[:set_num] == set_num
      set[:set_data][:set_cards].each do |card|
        # skip iteration unless desired set position
        next unless card[:set_pos] == set_pos
        return card[:card_data][:card_name], card[:card_data][:card_desc], set[:set_data][:set_name], set[:set_num], card[:set_pos]
      end
    end
  end

  # method to return card id from name
  def card_id(card_name)
    card_name = card_name.to_s.downcase.capitalize
    # iterate over sets and cards, and check for specific card name
    DECK.each do |set|
      set[:set_data][:set_cards].each do |card|
        # skip iteration unless desired card name
        next unless card[:card_data][:card_name] == card_name
        return set[:set_num], card[:set_pos]
      end
    end
  end

  # method to return array of other cards in a set from one card's id
  def card_set(set_num, set_pos)
    card_set = []
    DECK.each do |set|
      # skip iteration unless desired set number
      next unless set[:set_num] == set_num
      set[:set_data][:set_cards].each do |card|
        # skip iteration if initial card
        next if card[:set_pos] == set_pos
        card_set << card[:card_data][:card_name]
      end
      return card_set
    end
  end

  # method to return set data
  def set_data(set_num)
    DECK.each do |set|
      # skip iteration unless desired set number
      next unless set[:set_num] == set_num
      return set[:set_num], set[:set_data][:set_name], set[:set_data][:set_len]
    end
  end

  puts DECK
  gets

end
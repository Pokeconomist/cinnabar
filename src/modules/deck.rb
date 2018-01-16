require 'json'

# module handling creation and interaction with deck data
module Deck
  extend self

  # DECK CONSTRUCTION

  # get hash from json files, and convert keys to symbols (n.b. JSON files contain expansion information not yet used)
  CARDS = JSON.parse(File.read('.\data\cards.json'), symbolize_names: true)[:cards].freeze
  SETS = JSON.parse(File.read('.\data\sets.json'), symbolize_names: true)[:sets].freeze

  # method to create simplifies deck array (comprised of just card ids).
  def id_array
    CARDS.map { |card| [card[:setNumber], card[:setPosition]] }
  end

  # DECK ACCESS METHODS

  # method to return array of card data from id
  def card_data(set_num, set_pos)
    card = CARDS.select { |card| card[:setNumber] == set_num && card[:setPosition] == set_pos }[0]
    return card.nil? ? nil : [
      card[:cardName],
      card[:cardDescription],
      set_data(card[:setNumber])[1],
      card[:setNumber],
      card[:setPosition]
    ]
  end

  # method to return card id from name
  def card_id(card_name)
    card_name = card_name.to_s.downcase.capitalize
    card = CARDS.select { |card| card[:cardName] == card_name }[0]
    return card.nil? ? nil : [
      card[:setNumber],
      card[:setPosition]
    ]
  end

  # method to return array of other cards in a set from one card's id
  def card_set(set_num, set_pos)
    cards = CARDS.select { |card| card[:setNumber] == set_num && card[:setPosition] != set_pos }.map { |card| card[:cardName] }
  end

  # method to return set data
  def set_data(set_num)
    set = SETS.select { |set| set[:setNumber] == set_num }[0]
    return set.nil? ? nil : [
      set[:setNumber],
      set[:setName],
      set[:setLength]
    ]
  end
end
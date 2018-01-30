require 'json'

# Module containing card amd set data, and access methods.
module Deck
  extend self

  # Array of hashes containing card data from JSON file.
  #
  # i.e.
  #   [
  #     {
  #       cardName:        "Cinnabar",
  #       setNumber:       1,
  #       setPosition:     "A",
  #       cardDescription: "Mercury ore"
  #     },
  #     ...
  #   ]
  CARDS = JSON.parse(File.read('.\data\cards.json'), symbolize_names: true)[:cards].freeze

  # Array of hashes containing set data from JSON file.
  #
  # i.e.
  #   [
  #     {
  #       setNumber: 1,
  #       setLength: 5,
  #       setName:   "Sulphide Materials"
  #     },
  #     ...
  #   ]
  SETS = JSON.parse(File.read('.\data\sets.json'), symbolize_names: true)[:sets].freeze

  # Creates simplified deck array.
  # @return [Array<Array(Integer, String)>] Array of card ids
  def id_array
    CARDS.map { |card| [card[:setNumber], card[:setPosition]] }
  end

  # Returns card data given a card's id.
  # @param set_num [Integer] Card's set number
  # @param set_pos [String] Card's set position
  # @return [Array(String, String, Integer, Integer, String), nil] Array comprised of the card's name,
  #   description, set name, set number, and set position, or nil if card not found
  def card_data(set_num, set_pos)
    card = CARDS.select { |card| card[:setNumber] == set_num && card[:setPosition] == set_pos }[0]
    card.nil? ? nil : [
      card[:cardName],
      card[:cardDescription],
      set_data(card[:setNumber])[1],
      card[:setNumber],
      card[:setPosition]
    ]
  end

  # Returns a card's id given a card's name.
  # @param card_name [String]
  # @return [Array(Integer, String), nil] Card id, or nil if card not found
  def card_id(card_name)
    card_name = card_name.to_s.downcase.titleise
    card = CARDS.select { |card| card[:cardName] == card_name }[0]
    card.nil? ? nil : [
      card[:setNumber],
      card[:setPosition]
    ]
  end

  # Returns array of other cards in a set given a card's id.
  # @param (see #card_data)
  # @return [Array(String)] Array of card names of other cards in set
  def card_set(set_num, set_pos)
    CARDS.select { |card| card[:setNumber] == set_num && card[:setPosition] != set_pos }.map { |card| card[:cardName] }
  end

  # Returns set data given a set's number.
  # @param set_num [Integer] Set's number
  # @return [Array(Integer, String, Integer), nil] Array comprised of the set's number, name, and length, or nil if card not found
  def set_data(set_num)
    set = SETS.select { |set| set[:setNumber] == set_num }[0]
    set.nil? ? nil : [
      set[:setNumber],
      set[:setName],
      set[:setLength]
    ]
  end
end
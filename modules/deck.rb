# deck is made as a hash / array as below
# [
#   :set_num => $,
#   :set_data => ${
#     :set_name => $,
#     :set_cards => [
#       :set_pos => $,
#       :card_data => {
#         :card_name => $,
#         :card_desc => $,
#       ],
#       ...
#     },
#   },
#   ...
# ]
#
# i.e.
# array of sets (with attributes set_num and set_data, comprised of set_name, and set_cards
# which in turn is comprised of set_pos, and card_data, which is comprised of card_name, and card_desc)

require 'csv'

# module handling creation and interaction with deck data
module Deck
  extend self
    # test method
    def test
      print "DECK: THIS IS A TEST. THIS SHOULD NOT BE SEEN DURING NORMAL USE.\n"
    end

  # DECK CONSTRUCTION

  # get arrays from csv files, and convert relevant keys to integers
  CARDS = CSV.read('.\files\cards.csv').each do |cards|
    cards.map!.each_with_index do |element, index|
      index == 1 ? element.to_i : element
    end
  end
  SETS = CSV.read('.\files\sets.csv').each do |cards|
    cards.collect!.each_with_index do |element, index|
      index == 0 || index == 2 ? element.to_i : element
    end
  end

  DECK = []
  # iterate over sets and select cards from that set, and compile to deck hash
  SETS.each do |set|
    DECK << {
      :set_num => set[0], :set_data => {
        :set_name => set[1], :set_len =>  set[2], :set_cards => (
          # collect array of cards from specific set, and compile to deck hash
          CARDS.select { |card| card[1] == set[0] }.collect do |card|
            {
              :set_pos => card[2], :card_data => {
                :card_name => card[0], :card_desc => card[3]
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
end
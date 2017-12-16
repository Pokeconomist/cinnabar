# module controlling access to card / set data
# i.e. all interaction with the deck done through Deck module methods

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

# i.e.
# array of sets (with attributes set_num and set_data, comprised of set_name, and set_cards
# which in turn is comprised of set_pos, and card_data, which is comprised of card_name, and card_desc)

require 'csv'

# module handling creation and interaction with deck data
module Deck

  # get arrays from csv files, and convert relevant keys to int
  CARDS = CSV.read('../files/cards.csv').each do |cards|
    cards.map!.each_with_index do |element, index|
      index == 1 ? element.to_i : element
    end
  end
  SETS = CSV.read('../files/sets.csv').each do |cards|
    cards.collect!.each_with_index do |element, index|
      index == 0 || index == 2 ? element.to_i : element
    end
  end

  DECK = []
  # iterate of sets and select cards from that set, and complie to deck hash
  SETS.each do |set|
    DECK << {
      :set_num => set[0], :set_data => {
        :set_name => set[1], :set_len =>  set[3], :set_cards => (
          CARDS.select { |card| card[1] == 1 }.collect do |card|
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

  # # method to retrieve card data
  # def card_data(set_num, set_pos)
  #   card = DECK.select { |set| set[:set_num] == set_num }[:set_data][:set_data].select { |card| card[:set_pos] == set_pos }
  #   return card[:card_data][:card_name], card[:card_data][:card_desc], set[:set_data][:set_name], set[:set_num], card[:set_pos]
  # end

end

# TODO: Implement deck data access methods (card_data, card_id, card_set)
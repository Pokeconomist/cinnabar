# deck creation module

# deck is made as a hash/array as below
# [
#   :set_num => $,
#   :set_data => ${
#     :set_name => $,
#   :  set_cards => [
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
# array of sets (with attributes set_num and set_data, comprised of set_name, and set_cards , which in turn is comprised of set_pos, and card_data, which is comprised of card_name, and card_desc)

require 'csv'

# class to create set elements from csv
class Set
  attr_reader :set

  # get arrays from csv files, and convert relevant keys to int
  @@CARDS = CSV.read('files/cards.csv').each do |cards|
    cards.map!.each_with_index do |element, index|
      index == 1 ? element.to_i : element
    end
  end
  @@SETS = CSV.read('files/sets.csv').each do |cards|
    cards.collect!.each_with_index do |element, index|
      index == 0 || index == 2 ? element.to_i : element
    end
  end

  # create hash for a set
def initialize(line_num)
  set_num = @@SETS[line_num][0]
  set_name = @@SETS[line_num][1]
  set_length = @@SETS[line_num][2]
  @set = {:set_num => set_num, :set_data => {:set_name => set_name, :set_length => set_length, :set_cards => (Set.compile_cards(set_num))}}
end
  # create array of all cards within a set (and organise data)
  def self.compile_cards(set_num)
    # find cards of set number == set_num, and return their data as a hash
    @@CARDS.select { |card| card[1] == set_num }.collect { |card| {:set_pos => card[2], :card_data => {:card_name => card[0], :card_desc => card[3]} } }
  end
end

# module handling deck creation
module Deck
  extend self

  # create array of set hashes
  DECK = Array.new(12) { |n| Set.new(n).set }

  # create hash of card ids with name as key (eg. {:cinnabar => [1, "A"]...})
  def compile_id_array
    cards = []
    DECK.each do |set|
      set[:set_data][:set_cards].each do |card|
        cards << [set[:set_num], card[:set_pos]]
      end
    end
    cards
  end

  # method to return data for a specified card
  def card_data(set_num, set_pos)
    DECK.each do |set|
      # find set
      if set[:set_num] == set_num
        # iterate over set
        set[:set_data][:set_cards].each do |card|
          # find card
          if card[:set_pos] == set_pos
            return card[:card_data][:card_name], card[:card_data][:card_desc], set[:set_data][:set_name], set[:set_num], card[:set_pos]
          end
        end
      end
    end
  end

  # function to return other cards in set
  def card_set(set_num, set_pos)
    card_set = []
    DECK.each do |set|
      # find set
      if set[:set_num] == set_num
        # iterate over set
        set[:set_data][:set_cards].each do |card|
          # find all other cards
          if card[:set_pos] != set_pos
            card_set << card[:card_data][:card_name]
          end
        end
        return card_set
      end
    end
  end

  # method to get a cards id from its name (and validates input)
  def card_id(card_name)
    card_name = card_name.to_s.downcase.capitalize
    # iterate over sets
    DECK.each do |set|
      # iterate over cards
      set[:set_data][:set_cards].each do |card|
        # find card
        if card[:card_data][:card_name] == card_name
          return set[:set_num], card[:set_pos]
        end
      end
    end
  end
  # TODO: fix method // DONE 2017-07-15
  # method to check a hand for complete sets
  def check_set(hand)
    complete_sets = []
    # get all unique sets in hand
    sets = hand.collect { |card| card[0] }.uniq
    puts sets
    # check if each set complete
    sets.each do |set_num|
     complete_sets <<
      if hand.count { |card| card[0] == set_num } == DECK.select { |set| set[:set_num] == set_num }[0][:set_data][:set_length]
        {:set_num => test_card[0]}
      end
    end
    return complete_sets
  end
end
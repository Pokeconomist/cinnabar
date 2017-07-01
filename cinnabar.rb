#TODO posible shift to using a struct rather than an array

#eg.
#sets = Struct.new(:set_num, :set_data)
#set = Struct.new(:set_name, :set_cards)
#cards = Struct.new(:set_pos, :card_data)
#card = Struct.new(:card_name, :card_desc)
#deck = sets.new(1, set.new("Sulfide Minerals", cards.new("A", card.new("Cinnabar", "Mercury ore")...)...)
=begin
cards = Struct.new(:set_pos, :card_data)
card = Struct.new(:card_name, :card_desc)
@@cards.select {|card| card[1] == set_num}.each do |card|
	cards.new(card[2], card_data)
	card.new(card[0], card[3])
end
=end
#deck is made as a hash/array as below
#[
#	:set_num => ,
#	:set_data => {
#		:set_name => ,
#	:	set_cards => [
#			:set_pos => ,
#			:card_data => {
#				:card_name => ,
#				:card_desc => ,		
#			],
#			...
#		},
#	},
#	...
#]

#e.g.
#[
#	:set_num => 1,
#	:set_data => {
#		:set_name => "",
#	:	set_cards => [
#			:set_pos => ,
#			:card_data => {
#				:card_name => ,
#				:card_desc => ,		
#			],
#			...
#		},
#	},
#	...
#]

#i.e.
#	array of sets (with attributes set_num and set_data, comprised of set_name, and set_cards , which in turn is comprised of set_pos, and card_data, which is comprised of card_name, and card_desc)
require "csv"
require "pp"

#class to create set elements from csv
class Set
	attr_reader :set
	@@cards = CSV.read("files/cards.csv").each {|cards| cards.map!.each_with_index {|element, index| index == 1 ? element.to_i : element}}
	@@sets = CSV.read("files/sets.csv").each {|cards| cards.collect!.each_with_index {|element, index| index == 0 || index == 2 ? element.to_i : element}}
	#create hash of all cards within a set
	def self.compile_cards(set_num)
		@@cards.select {|card| card[1] == set_num}.collect {|card| {:set_pos => card[2], :card_data => {:card_name => card[0], :card_desc => card[3]}}}
	end
	#create hash for a set
	def initialize(line_num)
		set_num = @@sets[line_num][0]
		set_name = @@sets[line_num][1]
		@set = {:set_num => set_num, :set_data => {:set_name => set_name, :set_cards => (Set.compile_cards(set_num))}}
	end
end
#class to create the deck from all sets (12)
class Deck
	attr_reader :deck
	def initialize
		@deck = Array.new(12) {|n| Set.new(n).set}
	end
	def get_card_data(set_num, set_pos)
		@deck.each do |set|
			if set[:set_num] == set_num
				set[:set_data][:set_cards].each do |card|
					if card[:set_pos] == set_pos
						return card[:card_data][:card_name], card[:card_data][:card_desc], set[:set_data][:set_name], set[:set_num], card[:set_pos]
					else
						return nil
					end
				end
			else
				return nil
			end
		end
	end
	#function to return oher cards in set
	def get_card_set(set_num, set_pos)
		card_set = []
		@deck.each do |set|
			if set[:set_num] == set_num
				set[:set_data][:set_cards].each do |card|
					if card[:set_pos] != set_pos
						card_set << card[:card_data][:card_name]
					end
				end
				return card_set
			end
		end						
	end
end

#function that prints cards data
def print_card(card_name, card_desc, set_name, set_num, set_pos, card_set)
	card_set.each do |card|
		puts " #{card}"
	end
	puts "#{set_name}    #{set_num}-#{set_pos}"
	puts card_name.upcase
	puts "(" + card_desc + ")"
end
#init deck storage
deck = Deck.new


cards = Array.new {}
#example getting card data
print_card(*deck.get_card_data(1, "A"), deck.get_card_set(1, "A"))

run_game = false

while run_game
	turn = 0
	while turn == 0
	end
end
	


	
		
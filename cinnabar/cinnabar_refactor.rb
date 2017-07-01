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
#deck is made as a hash as below
#{:1 => {
#	:set_name => ,
#	:set_cards => {
#		:A => {
#			:card_name => ,
#			:card_desc => ,		
#		},
#		...
#	},
#	...
#}
#OR
#DECK {
#	set_num => SETS {
#		:set_name
#		CARDS {
#			:set_pos => CARD {
#				:card_name
#				:card_desc
#			}
#			...
#		}
#	}
#	...
#}

#i.e.
#	array of sets (with key = set_num, comprised of set_name, set_size, and set_cards (each referenced by their relevent symbol), which in turn is comprised of each card with set_pos as the symbol)
require "csv"

#class to create set elements from csv
class Set
	attr_reader :set
	@@cards = CSV.read("files/cards.csv").each {|cards| cards.map!.each_with_index {|element, index| index == 1 ? element.to_i : element}}
	@@sets  = CSV.read("files/sets.csv").each {|cards| cards.collect!.each_with_index {|element, index| index == 0 || index == 2 ? element.to_i : element}}
	#create hash of all cards within a set
	def self.compile_cards(set_num)
		@@cards.select {|card| card[1] == set_num}.collect {|card| {card[2].to_sym => {:card_name => card[0], :card_desc => card[3]}}}.inject(:merge)
	end
	#create hash for a set
	def initialize(num)
		set_num = @@sets[num][0]
		set_name = @@sets[num][1]
		@set = {set_num => {:set_name => set_name, :set_cards => (Set.compile_cards(set_num))}}
	end
end
#class to create the deck from all sets (12)
class Deck
	attr_reader :deck
	def initialize
		@deck = Array.new(11) {|n| Set.new(n).set}
	end
end

puts Deck.new.deck


run_game = false
while run_game
	player1_hand = cards.sample(6)
	player2_hand = cards.sample(6)
	player3_hand = cards.sample(6)
	reserve = cards.delete()
	print "Player 1's turn. Press enter to continue:"
	pause
	player1_hand.each do |card|
		print_card(card[0])
	end
end
	


	
		
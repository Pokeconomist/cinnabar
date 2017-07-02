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
	#create array of all cards within a set
	def self.compile_cards(set_num)
		#find cards of set number == set_num, and return their data as a hash
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
	#create hash of set elements, 
	def initialize
		@deck = Array.new(12) {|n| Set.new(n).set}
	end
	#create hash of card ids with mname as key (eg. {:cinnabar => [1, "A"]...})
	def get_id_array
		cards = []
		@deck.each do |set|
			set[:set_data][:set_cards].each do |card|		
				cards << [set[:set_num], card[:set_pos]]
			end
		end
		return cards
	end
	#method to return data for a specified card
	def get_card_data(set_num, set_pos)
		@deck.each do |set|
			#find set
			if set[:set_num] == set_num
				#iterate over set
				set[:set_data][:set_cards].each do |card|
					#find card
					if card[:set_pos] == set_pos
						return card[:card_data][:card_name], card[:card_data][:card_desc], set[:set_data][:set_name], set[:set_num], card[:set_pos]
					end
				end
			end
		end
	end
	#function to return oher cards in set
	def get_card_set(set_num, set_pos)
		card_set = []
		@deck.each do |set|
			#find set
			if set[:set_num] == set_num
				#iterate over set
				set[:set_data][:set_cards].each do |card|
					#find all other cards
					if card[:set_pos] != set_pos
						card_set << card[:card_data][:card_name]
					end
				end
				return card_set
			end
		end						
	end
	#method to get a cards id from its name
	def get_card_id_from_name(card_name)
		raise Argument Error, "Please enter a valid card name" unless card.is_a? String
		card_name = card_name.downcase.capitalize
		@deck.each do |set|
			set[:set_data][:set_cards].each do |card|
				if card[:card_data][:card_name] == card_name
					return set[:set_num], card[:set_pos]
				end
			end
		end
		raise Argument Error, "Please enter a valid card name"
	end
end
#TOTO add class to handle players (mainly turn functions)
#special functions
def pause
	gets
end
def cls
	system("cls")
end

#function that prints cards data
def print_card(card_name, card_desc, set_name, set_num, set_pos, card_set)
	puts "----------------"
	card_set.each do |card|
		puts " #{card}"
	end
	puts "#{set_name}    #{set_num}-#{set_pos}"
	puts "  #{card_name.upcase}"
	puts "(" + card_desc + ")"
	puts "----------------"
end
#single line card print for debugging
def quick_print_card(card_name, card_desc, set_name, set_num, set_pos, card_set)
	puts card_name
end
#function to get a players hand (sorted), and to decrease the reserve pile
def get_hand(cards)
	hand = cards.sample(6)
	cards -= [hand]
	return hand.sort, cards
end

#init deck storage
deck = Deck.new

#array of acceptable card ids (cards servers as a static list, reserve serves as pickup pile)
#eg. [[1, "A"], [1, "B"],...]
cards = deck.get_id_array
reserve = deck.get_id_array

#WIP add actual game logic

run_game = true

while run_game
	turn = 0
	while turn == 0
		#init playeres hands
		player1_hand, reserve = get_hand(reserve)
		player2_hand, reserve = get_hand(reserve)
		player3_hand, reserve = get_hand(reserve)
		turn += 1
	end

#TODO create turn method to avoid 3x repeat

	print "PLAYER 1's TURN. Press enter to continue..."
	pause
	puts "Your cards are"
	player1_hand.each do |card|
		print_card(*deck.get_card_data(*card), deck.get_card_set(*card))
	end
	card_correct = false
	#TODO check each card against cards in sets, and current cards
	while !card_correct
		print "What card do you want (only from sets you have): "
		player1_wanted_card_name = gets
		player1_hand.each do |card|
			if deck.get_card_id_from_name(player1_wanted_card_name) == card[1]
				card_correct = true
			end
		end
	end
	player1_wanted_player = gets

	#pseudocode

	# if player{n}_cards.contains? (player1_wanted_card.id)
	# 	move_card(player1_cards, player{n}_cards)
	# end

end
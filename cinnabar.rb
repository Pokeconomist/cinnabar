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
		@@deck = Array.new(12) {|n| Set.new(n).set}
	end
	#create hash of card ids with mname as key (eg. {:cinnabar => [1, "A"]...})
	def self.get_id_array
		cards = []
		@@deck.each do |set|
			set[:set_data][:set_cards].each do |card|		
				cards << [set[:set_num], card[:set_pos]]
			end
		end
		return cards
	end
	#method to return data for a specified card
	def self.get_card_data(set_num, set_pos)
		@@deck.each do |set|
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
	#function to return other cards in set
	def self.get_card_set(set_num, set_pos)
		card_set = []
		@@deck.each do |set|
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
	#method to get a cards id from its name (ad validates input)
	def self.get_card_id_from_name(card_name)
		card_name = card_name.to_s.downcase.capitalize
		@@deck.each do |set|
			set[:set_data][:set_cards].each do |card|
				if card[:card_data][:card_name] == card_name
					return set[:set_num], card[:set_pos]
				end
			end
		end
		raise ArgumentError
	end
end
#WIP add class to handle players (mainly turn functions)
class Player
	attr_reader :hand, :reserve
	def initialize(player_num, cards)
		@player_num = player_num
		@hand, @reserve = self.get_hand(cards)
	end
	#function to get a players hand (sorted), and to decrease the reserve pile
	def get_hand(cards)
		hand = cards.sample(6)
		cards -= [hand]
		return hand.sort, cards
	end
	def player_turn
		print "PLAYER #{@player_num}'s TURN. Press enter to continue..."
		pause
		puts "Your cards are"
		@hand.each do |card|
			print_card(*Deck.get_card_data(*card), Deck.get_card_set(*card))
		end
		card_correct = false
		#TODO check each card against cards in sets, and current cards //DONE
		while !card_correct
			print "What card do you want (only from sets you have): "
			wanted_card_name = gets.chomp
			@hand.each do |card|
				begin
					#check against sets, and validate input
					if (Deck.get_card_id_from_name(wanted_card_name)[0] == card[0]) && !(card.include? (Deck.get_card_id_from_name(wanted_card_name)))
						card_correct = true
					end
				rescue ArgumentError
					puts "Please enter a valid card name..."
					card_correct = false
					break
				end
			end
		end
		player_correct = false
		while !player_correct
			print "What player do you call: "
			called_player = gets.chomp.to_i
			if (called_player == @player_num) || called_player > 3 || called_player <= 0
				puts "Please enter a valid player number..."
				player_correct = false
			else				
				player_correct = true
			end
		end
		def check_card(card_id)
			return @hand.include? (card_id), true
		end
		
		#TODO call check card on another player object

		#pseudocode

		# if player{n}_cards.contains? (player1_wanted_card.id)
		# 	move_card(player1_cards, player{n}_cards)
		# end
	end
end
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

#init deck storage
Deck.new

#array of acceptable card ids (cards servers as a static list, reserve serves as pickup pile)
#eg. [[1, "A"], [1, "B"],...]
cards = Deck.get_id_array
reserve = Deck.get_id_array

#WIP add actual game logic

run_game = true

while run_game
	turn = 0
	while turn == 0
		#init player objects and decrease reserve

		#TODO implement better reserve pile handling

		player1 = Player.new(1, reserve)
		reserve = player1.reserve
		player2 = Player.new(2, reserve)
		reserve = player2.reserve
		player3 = Player.new(3, reserve)
		reserve = player3.reserve
		turn += 1
	end

#TODO create turn method to avoid 3x repeat
	player1.player_turn

end
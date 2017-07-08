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
	def self.get_card_id(card_name)
		card_name = card_name.to_s.downcase.capitalize
		@@deck.each do |set|
			set[:set_data][:set_cards].each do |card|
				if card[:card_data][:card_name] == card_name
					return set[:set_num], card[:set_pos]
				end
			end
		end
	end
end

#WIP add class to handle players (mainly turn functions)
class Player
	attr_reader :reserve, :player_num, :wanted_card_id, :called_player, :hand
	#init method, that creates all player attr, and a diminished reserve variable (only used by main scope)
	def initialize(player_num, cards)
		@player_num = player_num
		@hand, @reserve = self.get_hand(cards)
	end
	#method to get a players hand (sorted), and to return a decreased reserve pile
	def get_hand(cards)
		hand = cards.sample(6)
		cards -= [hand]
		return hand.sort, cards
	end
	#method to get a players inputs
	def player_turn
		puts "Your cards are"
		@hand.each do |card|
			print_card(*Deck.get_card_data(*card), Deck.get_card_set(*card))
		end

		#TODO find solution that doent use instance variables

		#get and check input for card name
		@wanted_card_id = get_wanted_card()
		#get and check input for player number
		@called_player = get_wanted_player()
	end
	#method to get / check a players wanted card input 
	def get_wanted_card
		while true
			print "What card do you want (only from sets you have): "
			wanted_card_name = gets.chomp
			#check against sets, and validate input
			if (@hand.collect {|e| e[0]}.include? (Deck.get_card_id(wanted_card_name)[0])) && !(@hand.include? (Deck.get_card_id(wanted_card_name)))
				return Deck.get_card_id(wanted_card_name)
			else 
				puts "Please enter a valid card name..."
			end
		end
	end
	#method to get / check wanted player input
	def get_wanted_player
		while true
			print "What player do you call: "
			called_player = gets.chomp.to_i
			if !(called_player == @player_num) && called_player <= 3 && called_player >= 1
				return called_player
			else
				puts "Please enter a valid player number..."
			end
		end
	end
	#methods to take and give cards to a player
	def add_card(card_id)
		@hand += [card_id]
	end
	def take_card(card_id)
		@hand -= [card_id]
	end
end

#@turn_data instance variable used to specify what occured during the last turn, and notify other players
#@turn_data = [{:card_taken => $bool$, :called_player => $int$, card => $arr$}, ...]
#card_taken true of player [:called_player] has [:card]
#can check for all cases with these vars
#ie.
#	p call p[n] - doesn't have card / has card
#						|				|-> call again >> @turn_data
#					end turn
#thus @turn_array[-1] == false for all cases

#class to handle game turns
class Game
	attr_reader :reserve
	def initialize(cards)
		@turn_data = []
		@reserve = cards
		@player1 = Player.new(1, @reserve)
		@reserve = @player1.reserve
		@player2 = Player.new(2, @reserve)
		@reserve = @player2.reserve
		@player3 = Player.new(3, @reserve)
		@reserve = @player3.reserve
		@players = [@player1, @player2, @player3]
	end
	def game_turn
		(0..2).each do |n|
			cls
			#notify other players of past turn (using player[n].turn_data)
			if @turn_data != []
				@turn_data.each do |card|
					if card[:card_taken]
						puts "Player #{@players[n - 1].player_num} took #{Deck.get_card_data(*card[:card])[0]} from Player #{card[:called_player]}"

					elsif !card[:card_taken]
						puts "Player #{@players[n - 1].player_num} asked Player #{card[:called_player]} for #{Deck.get_card_data(*card[:card])[0]} and was denied"
					end
				end
			end
			@turn_data = []
			print "PLAYER #{n + 1}'s TURN. Press enter to continue..."
			pause
			cls
			@players[n].player_turn
			check_card(@players[n].player_num, @players[n].called_player, @players[n].wanted_card_id)
		end
	end

	#TODO loop if card_taken == true

	def check_card(player_num, called_player_num, card_id)
		if @players[called_player_num - 1].hand.include? (card_id)
			@players[called_player_num - 1].take_card(card_id)
			@players[player_num - 1].add_card(card_id)
			"Player #{called_player_num} had the card"
			card_taken = true
		else
			puts "Player #{called_player_num} didn't have the card..."
			card_taken = false
		end
		@turn_data << {:card_taken => card_taken, :called_player => called_player_num, :card => card_id}
		pause
	end
end
#independent functions
def pause
	gets
end
def cls
	system("cls")
end

#game functions
#function that prints cards data
def print_card(card_name, card_desc, set_name, set_num, set_pos, card_set)
	puts "----------------"
	card_set.each do |card|
		puts " #{card}"
	end
	puts "#{set_name.upcase}    #{set_num}-#{set_pos}"
	puts "  #{card_name.upcase}"
	puts "(#{card_desc})"
	puts "----------------"
end
#single line card print for debugging
def quick_print_card(card_name, card_desc, set_name, set_num, set_pos, card_set)
	puts card_name
end

#init deck storage
Deck.new

#array of acceptable card ids (cards serves as a static list, reserve serves as pickup pile)
#eg. [[1, "A"], [1, "B"],...]
cards = Deck.get_id_array
reserve = Deck.get_id_array

run_game = true
while run_game
	turn = 0
	while turn == 0

		#TODO implement better reserve pile handling

		#init game object and decrease reserve

		turn += 1
	end
	game = Game.new (reserve)
	reserve = game.reserve
	game.game_turn
	
end
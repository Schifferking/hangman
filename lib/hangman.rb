require 'yaml'

module Selectable
  def load_words
    File.readlines('/home/schifferking/repos/ruby/hangman/lib/google-10000-english-no-swears.txt')
  end

  def trim_words(words)
    words.each { |word| word.chomp! }
  end

  def filter_words(words)
    words.select { |word| word.length >= 5 && word.length <= 12 }
  end

  def set_dictionary
    filter_words(trim_words(load_words))
  end

  def get_word(dictionary)
    dictionary.sample
  end
end

class Game
  include Selectable
  attr_accessor :secret_word, :word, :player, :turn, :guessed_letters

  def initialize(player)
    @player = player
    @word = get_word(set_dictionary)
    @secret_word = ''
    @turn = 1
    @guessed_letters = ''
    update_secret_word
  end

  def display_player_tries
    puts "You have #{player.tries} tries left"
    puts
  end

  def update_secret_word
    @secret_word = ''
    word.split('').each do |letter|
      if guessed_letters.include?(letter)
        @secret_word += letter
      else
        @secret_word += '_'
      end
    end
  end

  def display_secret_word
    secret_word.split('').each { |letter| print "#{letter} " }
    puts
    puts
  end

  def ask_player_letter
    print 'Please enter a valid letter: '
  end

  def letter?(inp)
    ('a'..'z').to_a.include?(inp)
  end

  def letter_in_word?(letter)
    word.include?(letter)
  end

  def display_turn
    puts "Turn #{turn}"
    puts
  end

  def display_information
    display_turn
    display_secret_word
    display_player_tries
    ask_player_letter
  end

  def obtain_player_letter
    letter = nil

    until letter?(letter) && !guessed_letters.include?(letter)
      letter = player.enter_letter
      save_game if letter == 'save'
      break if letter?(letter) && !guessed_letters.include?(letter)

      ask_player_letter
    end
    puts
    letter
  end

  def remove_player_try
    player.tries -= 1
  end

  def add_turn
    @turn += 1
  end

  def update_guessed_letters(letter)
    @guessed_letters += letter
  end

  def analyze_letter(letter)
    if letter_in_word?(letter)
      update_guessed_letters(letter)
    else
      remove_player_try
    end
  end

  def win?
    @secret_word == @word
  end

  def display_word
    puts word
  end

  def display_lose_message
    puts 'You lose!' unless win?
  end

  def display_endgame_message
    display_lose_message
    display_word
  end

  def calculate_results
    letter = obtain_player_letter
    analyze_letter(letter)
    update_secret_word
  end

  def play_game
    while player.tries.positive?
      display_information
      calculate_results
      if win?
        puts 'You won!'
        break
      end
      add_turn
    end
    display_endgame_message
  end

  def display_overwrite_message
    puts
    puts 'It currently exists a file with that name.'
    print 'Do you want to overwrite your save (y/n)? '
  end

  def display_save_message
    puts
    puts 'You can save this game each turn if you enter the word save.'
    puts 'Note: if you save the game, then the game will close.'
    puts
  end

  def to_yaml
    YAML.dump({
                player: @player,
                word: @word,
                secret_word: @secret_word,
                turn: @turn,
                guessed_letters: @guessed_letters
              })
  end

  def save_file(filename)
    class_serialized = to_yaml
    game_file = File.open(filename, 'w')
    game_file.puts class_serialized
    game_file.close
  end

  def save_game
    path = '/home/schifferking/repos/ruby/hangman/saves/'
    filename = "#{path}#{ask_file_name}.yaml"
    while File.exist?(filename)
      display_overwrite_message
      player_response = player.enter_letter
      break if player_response == 'y'

      filename = "#{path}#{ask_file_name}.yaml"
    end
    save_file(filename)
    abort
  end
end

class Player
  attr_accessor :tries

  def initialize
    @tries = 8
  end

  def enter_letter
    gets.chomp.downcase
  end
end

def start_game(game)
  game.display_save_message
  game.play_game
end

def ask_file_name
  print 'Please enter the file name: '
  gets.chomp
end

def ask_player_action
  print 'If you want to load a save, please enter load: '
  gets.chomp.downcase
end

def obtain_valid_filename(path)
  extension = '.yaml'
  filename = "#{path}#{ask_file_name}#{extension}"
  until File.exist?(filename)
    puts 'Filename not valid'
    filename = "#{path}#{ask_file_name}#{extension}"
  end
  filename
end

def load_file(filename)
  File.open(filename, 'r') { |file| file.read }
end

def from_yaml(file_contents)
  data = YAML.load file_contents
  g = Game.new(data[:player])
  g.word = data[:word]
  g.turn = data[:turn]
  g.guessed_letters = data[:guessed_letters]
  g.update_secret_word
  g
end

def load_game(path)
  filename = obtain_valid_filename(path)
  file_content = load_file(filename)
  from_yaml(file_content)
end

def analyze_player_action(action)
  path = '/home/schifferking/repos/ruby/hangman/saves/'
  if action == 'load'
    if Dir.glob("#{path}*").size.zero?
      puts 'There are no files saved'
      puts 'Starting a new game'
      Game.new(Player.new)
    else
      load_game(path)
    end
  else
    Game.new(Player.new)
  end
end

result = analyze_player_action(ask_player_action)
start_game(result)

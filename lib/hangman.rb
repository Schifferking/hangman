module Selectable
  def load_words
    File.readlines('google-10000-english-no-swears.txt')
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
  attr_accessor :secret_word, :word, :player, :turn

  def initialize(player)
    @player = player
    @word = get_word(set_dictionary)
    @secret_word = ''
    @turn = 1
  end

  def display_player_tries
    puts "You have #{player.tries} tries left"
    puts
  end

  def update_secret_word
    word.split('').each { @secret_word += '_' }
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
    update_secret_word
    display_secret_word
    display_player_tries
    ask_player_letter
  end

  def obtain_player_letter
    letter = nil

    until letter?(letter)
      letter = player.enter_letter
      ask_player_letter
    end
    letter
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

pl = Player.new
g = Game.new(pl)
g.display_information
letter = g.obtain_player_letter
g.letter_in_word?(letter)

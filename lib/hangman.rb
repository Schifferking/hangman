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
  attr_accessor :secret_word, :word, :player

  def initialize(player)
    @player = player
    @word = get_word(set_dictionary)
    @secret_word = ''
  end

  def display_player_tries
    puts "You have #{player.tries} tries left"
  end

  def update_secret_word
    word.split('').each { @secret_word += '_' }
  end

  def display_secret_word
    secret_word.split('').each { |letter| print "#{letter} " }
  end

  def ask_player_letter
    puts 'Please enter a valid letter'
    player.enter_letter
  end

  def letter?(inp)
    ('a'..'z').to_a.include?(inp)
  end

  def letter_in_word?(letter)
    word.include?(letter)
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
p g.word
p g.letter_in_word?(pl.enter_letter)

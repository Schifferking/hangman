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
  attr_accessor :word, :player

  def initialize(player)
    @player = player
    @word = get_word(set_dictionary)
  end

  def display_player_tries
    puts "You have #{player.tries} tries left"
  end
end

class Player
  attr_accessor :tries

  def initialize
    @tries = 8
  end

  def enter_letter
    gets
  end
end

pl = Player.new
g = Game.new(pl)

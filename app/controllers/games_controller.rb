require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = ('A'..'Z').to_a.sample(10)
    session["score"] = 0 if session["score"].nil?
  end

  def score
    @word = params[:word]
    @letters = params[:letters]
    @score_now = 0
    word_serialized = open("https://wagon-dictionary.herokuapp.com/#{@word}").read
    @english_word = JSON.parse(word_serialized)['found']

    good_number = not_too_much(@letters, @word)

    if !good_number
      @result_sentence = "Sorry but #{@word.upcase} can't be built out of #{@letters}"
    elsif @english_word == false
      @result_sentence = "Sorry but #{@word.upcase} is not an english word..."
    else
      @result_sentence = "Congratulation! #{@word.upcase} is an english word !"
      session['score'] += @word.length * @word.length
      @score_now = @word.length * @word.length
    end
    @score = session['score']
  end

  private

  def not_too_much(grid, attempt)
    answer = true

    hash_grid = {}
    grid.split('').each { |letter| hash_grid[letter.upcase].nil? ? hash_grid[letter.upcase] = 1 : hash_grid[letter.upcase] += 1 }

    hash_attempt = {}
    attempt.upcase.split('').each do |letter|
      hash_attempt[letter].nil? ? hash_attempt[letter] = 1 : hash_attempt[letter] += 1
    end

    hash_attempt.each_pair { |key, value| answer = false if (value.to_i > hash_grid[key].to_i) || (hash_grid[key].nil?) }
    answer
  end
end

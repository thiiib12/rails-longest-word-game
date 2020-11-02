require 'open-uri'
require 'json'
require 'time'

class GamesController < ApplicationController
  def new
    @grid = generate_grid(10)
    @start_time = Time.now
  end

  def score
    @answer = params[:answer]
    @start_time = Time.parse(params[:start_time])
    @grid = params[:grid]
    @timediff = Time.now - @start_time
    @result = run_game(@answer, @timediff)
  end

  private

  def generate_grid(grid_size)
    grid = []
    grid_size.times { grid << ('A'..'Z').to_a.sample(1)[0] }
    grid
  end

  def run_game(attempt, time_diff)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    info = JSON.parse(open(url).read)
    if match?(attempt, @grid, info) == true
      score = attempt.length.fdiv(2) * (100 / time_diff)
      { time: time_diff, score: score, message: "1" }
    else
      { time: time_diff, score: 0, message: match?(attempt, @grid, info) }
    end
  end

  def match?(attempt, grid, info)
    return '3' unless info['found']
    attempt.upcase.chars.each do |letter|
      if grid.include?(letter)
        grid.sub!(letter, '')
      else return "2"
      end
    end
    true
  end
end

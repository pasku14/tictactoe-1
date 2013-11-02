require 'rubygems'
require 'sinatra'

settings.port = ENV['PORT'] || 4567
enable :sessions
use Rack::Session::Pool, :expire_after => 2592000
set :session_secret, 'super secret'
set :sessions, :domain => 'example.com'

module TicTacToe
  CIRCLE = "circle"
  CROSS  = "cross"
  BLANK  = ""
end 

class Board
include TicTacToe

  HORIZONTALS = [ %w{a1 a2 a3},  %w{b1 b2 b3}, %w{c1 c2 c3} ]
  COLUMNS     = [ %w{a1 b1 c1},  %w{a2 b2 c2}, %w{a3 b3 c3} ]
  DIAGONALS   = [ %w{a1 b2 c3},  %w{a3 b2 c1} ]
  ROWS = HORIZONTALS + COLUMNS + DIAGONALS
  MOVES       = %w{a1    a2   a3   b1   b2   b3   c1   c2   c3}

  def initialize(session) 
    @session = session
    @session["board"] = {}
    MOVES.each do |k|
      @session["board"][k] = BLANK
    end
  end

  def board
    @session["board"]
  end

  def [] key
    @session["board"][key]
  end

  def []= key, value
    @session["board"][key] = value
  end

  def legal_moves
    m = []
    MOVES.each do |key|
      m << key if @session["board"][key] == BLANK
    end
    puts "legal_moves: Tablero:  #{board.inspect}"
    puts "legal_moves: m:  #{m}"
    m # returns the set of feasible moves [ "b3", "c2", ... ]
  end

  def winner
    ROWS.each do |row|
      circles = row.find_all{ |s| self[s] == CIRCLE  }.size 
      puts "winner: #{row.inspect} circles=#{circles}"
      return CIRCLE if circles == 3  # "circle" wins
      crosses = row.find_all{ |s| self[s] == CROSS  }.size   
      puts "winner: #{row.inspect} crosses=#{crosses}"
      return CROSS  if crosses == 3
    end
    false
  end
end

include TicTacToe
get %r{^/([abc][123])?$} do |human|
  if human then
    puts "You played: #{human}!"
    if BOARD.legal_moves.include? human
      BOARD[human] = CIRCLE
      computer = BOARD.legal_moves.sample
      redirect to ('humanwins') if BOARD.winner == CIRCLE
      redirect to('/') unless computer
      BOARD[computer] = CROSS
      puts "I played: #{computer}!"
      puts "Tablero:  #{BOARD.board.inspect}"
    end
  else
    puts Board::HORIZONTALS.inspect
    BOARD = Board.new(session)
  end
  erb :game, :locals => { :b => BOARD, :m => ''  }
end

get '/humanwins' do
  erb :final, :locals => { :b => BOARD, :m => 'Human wins' }
  #sleep(2)
  #redirect to('/')
end

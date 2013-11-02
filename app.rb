require 'rubygems'
require 'sinatra'

settings.port = ENV['PORT'] || 4567
enable :sessions
use Rack::Session::Pool, :expire_after => 2592000
set :session_secret, 'super secret'
set :sessions, :domain => 'example.com'

class Board

  HORIZONTALS = [ %w{a1 a2 a3},  %w{b1 b2 b3}, %w{c1 c2 c3} ]
  COLUMNS     = [ %w{a1 b1 c1},  %w{a2 b2 c2}, %w{a3 b3 c3} ]
  DIAGONALS   = [ %w{a1 b2 c3},  %w{a3 b2 c1} ]
  ROWS = HORIZONTALS + COLUMNS + DIAGONALS
  MOVES       = %w{a1    a2   a3   b1   b2   b3   c1   c2   c3}

  def initialize(session) 
    @session = session
    @session["board"] = {}
    MOVES.each do |k|
      @session["board"][k] = ""
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
      m << key unless @session["board"][key].length > 0
    end
    puts "legal_moves: Tablero:  #{board.inspect}"
    puts "legal_moves: m:  #{m}"
    m # returns the set of feasible moves [ "b3", "c2", ... ]
  end

  def won?
    ROWS.each do |row|
      return "cross" if row.xs == 3 # "cross" wins
      return "circle" if row.os == 3 # "circle" wins
    end
    return " " if blanks == 0   # tie
    false
  end
end

CIRCLE = "circle"
CROSS  = "cross"
get %r{/([abc][123])?} do |human|
  if human then
    puts "You played: #{human}!"
    if BOARD.legal_moves.include? human
      BOARD[human] = CIRCLE
      computer = BOARD.legal_moves.sample
      redirect to('/') unless computer
      BOARD[computer] = CROSS
      puts "I played: #{computer}!"
      puts "Tablero:  #{BOARD.board.inspect}"
    end
  else
    puts Board::HORIZONTALS
    BOARD = Board.new(session)
  end
  erb :game, :locals => { :b => BOARD }
end

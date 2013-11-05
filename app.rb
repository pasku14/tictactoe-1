require 'sinatra'
require 'sass'

configure do
  enable :sessions
  settings.port = ENV['PORT'] || 3333
  #set :sessions, :domain => 'example.com'
  use Rack::Session::Pool, :expire_after => 2592000
  set :session_secret, ENV['SESSION_SECRET'] ||= 'super secret'
end

#configure :development, :test do
#  set :sessions, :domain => 'example.com'
#end
#
#configure :production do
#  set :sessions, :domain => 'herokuapp.com'
#end

module TicTacToe
  HUMAN = CIRCLE = "circle" # human
  COMPUTER = CROSS  = "cross"  # computer
  BLANK  = ""

  def number_of(symbol, row)
    row.find_all{ |s| self[s] == symbol }.size 
  end
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
    Board.board = @session["board"] = Board.new(session) unless @session 
    Board.board
  end

  def self.board 
    @board
  end

  def self.board=(val) 
    @board = val
  end

  def [] key
    @session["board"][key]
  end

  def []= key, value
    @session["board"][key] = value
  end

  def each 
    MOVES.each do |move|
      yield move
    end
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
      circles = number_of(CIRCLE, row)  
      #puts "winner: #{row.inspect} circles=#{circles}"
      return CIRCLE if circles == 3  # "circle" wins
      crosses = number_of(CROSS, row)   
      #puts "winner: #{row.inspect} crosses=#{crosses}"
      return CROSS  if crosses == 3
    end
    false
  end

  def smart_move
    moves = legal_moves

    ROWS.each do |row|
      if (number_of(BLANK, row) == 1) then
        if (number_of(CROSS, row) == 2) then # If I have a win, take it.  
          row.each do |e|
            return e if self[e] == BLANK
          end
        end
      end
    end
    ROWS.each do |row|
      if (number_of(BLANK, row) == 1) then
        if (number_of(CIRCLE,row) == 2) then # If he is threatening to win, stop it.
          row.each do |e|
            return e if self[e] == BLANK
          end
        end
      end
    end

    # Take the center if open.
    return "b2" if moves.include? "b2"

    # Defend opposite corners.
    if    self["a1"] != COMPUTER and self["a1"] != BLANK and self["c3"] == BLANK
      return "c3"
    elsif self["c3"] != COMPUTER and self["c3"] != BLANK and self["a1"] == BLANK
      return "a1"
    elsif self["a3"] != COMPUTER and self["a3"] != BLANK and self["c1"] == BLANK
      return "c1"
    elsif self["c1"] != COMPUTER and self["c3"] != BLANK and self["a3"] == BLANK
      return "a3"
    end
    
    # Or make a random move.
    moves[rand(moves.size)]
  end
end

helpers do

  def human_wins?
    Board.board.winner == HUMAN
  end

  def computer_wins?
    Board.board.winner == COMPUTER
  end
end

include TicTacToe
get %r{^/([abc][123])?$} do |human|
  if human then
    puts "You played: #{human}!"
    if Board.board.legal_moves.include? human
      Board.board[human] = CIRCLE
      # computer = Board.board.legal_moves.sample
      computer = Board.board.smart_move
      redirect to ('humanwins') if Board.board.winner == CIRCLE
      redirect to('/') unless computer
      Board.board[computer] = CROSS
      puts "I played: #{computer}!"
      puts "Board:  #{Board.board.board.inspect}"
      redirect to ('computerwins') if Board.board.winner == CROSS
    end
  else
    puts Board::HORIZONTALS.inspect
    Board.board = Board.new(session)
  end
  haml :game, :locals => { :b => Board.board, :m => ''  }
end

get '/humanwins' do
  begin
    m = if human_wins? then
          'Human wins'
        else 
          redirect '/'
        end
    haml :final, :locals => { :b => Board.board, :m => m }
  rescue
    redirect '/'
  end
end

get '/computerwins' do
  begin
    m = if computer_wins? then
          'Computer wins'
        else 
          redirect '/'
        end
    haml :final, :locals => { :b => Board.board, :m => m }
  rescue
    redirect '/'
  end
end

not_found do
  redirect '/'
end

get '/styles.css' do
  scss :styles
end

require 'sinatra'
require 'sass'
require 'pp'

settings.port = ENV['PORT'] || 4567
enable :sessions
#use Rack::Session::Pool, :expire_after => 2592000
#set :session_secret, 'super secret'

#configure :development, :test do
#  set :sessions, :domain => 'example.com'
#end

#configure :production do
#  set :sessions, :domain => 'herokuapp.com'
#end

module TicTacToe
  HUMAN = CIRCLE = "circle" # human
  COMPUTER = CROSS  = "cross"  # computer
  BLANK  = ""

  HORIZONTALS = [ %w{a1 a2 a3},  %w{b1 b2 b3}, %w{c1 c2 c3} ]
  COLUMNS     = [ %w{a1 b1 c1},  %w{a2 b2 c2}, %w{a3 b3 c3} ]
  DIAGONALS   = [ %w{a1 b2 c3},  %w{a3 b2 c1} ]
  ROWS = HORIZONTALS + COLUMNS + DIAGONALS
  MOVES       = %w{a1    a2   a3   b1   b2   b3   c1   c2   c3}

  def number_of(symbol, row)
    row.find_all{ |s| session["bs"][s] == symbol }.size 
  end

  def inicializa
    @board = {}
    MOVES.each do |k|
      @board[k] = BLANK
    end
    @board
  end

  def board
    session["bs"]
  end

  def [] key
    session["bs"][key]
  end

  def []= key, value
    session["bs"][key] = value
  end

  def each 
    MOVES.each do |move|
      yield move
    end
  end

  def legal_moves
    m = []
    MOVES.each do |key|
      m << key if session["bs"][key] == BLANK
    end
    puts "legal_moves: Tablero:  #{session["bs"].inspect}"
    puts "legal_moves: m:  #{m}"
    m # returns the set of feasible moves [ "b3", "c2", ... ]
  end

  def winner
    ROWS.each do |row|
      circles = number_of(CIRCLE, row)  
      puts "winner: circles=#{circles}"
      return CIRCLE if circles == 3  # "circle" wins
      crosses = number_of(CROSS, row)   
      puts "winner: crosses=#{crosses}"
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
            return e if session["bs"][e] == BLANK
          end
        end
      end
    end
    ROWS.each do |row|
      if (number_of(BLANK, row) == 1) then
        if (number_of(CIRCLE,row) == 2) then # If he is threatening to win, stop it.
          row.each do |e|
            return e if session["bs"][e] == BLANK
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

  def human_wins?
    winner == HUMAN
  end

  def computer_wins?
    winner == COMPUTER
  end
end

helpers TicTacToe

get %r{^/([abc][123])?$} do |human|
  if human then
    puts "You played: #{human}!"
    puts "session: "
    pp session
    if legal_moves.include? human
      session["bs"][human] = TicTacToe::CIRCLE
      # computer = session["bs"].legal_moves.sample
      computer = smart_move
      redirect to ('/humanwins') if human_wins?
      redirect to('/') unless computer
      session["bs"][computer] = TicTacToe::CROSS
      puts "I played: #{computer}!"
      puts "Tablero:  #{board.inspect}"
      redirect to ('/computerwins') if computer_wins?
    end
  else
    session["bs"] = inicializa()
    puts "session = "
    pp session
  end
  haml :game, :locals => { :b => session["bs"], :m => ''  }
end

get '/humanwins' do
  puts "/humanwins session="
  pp session
  begin
    m = if human_wins? then
          'Human wins'
        else 
          redirect '/'
        end
    haml :final, :locals => { :b => session["bs"], :m => m }
  rescue
    redirect '/'
  end
end

get '/computerwins' do
  puts "/computerwins"
  pp session
  begin
    m = if computer_wins? then
          'Computer wins'
        else 
          redirect '/'
        end
    haml :final, :locals => { :b => session["bs"], :m => m }
  rescue
    redirect '/'
  end
end

not_found do
  puts "not found!!!!!!!!!!!"
  session["bs"] = inicializa(session)
  haml :game, :locals => { :b => session["bs"], :m => 'Let us start a new game'  }
end

get '/styles.css' do
  scss :styles
end

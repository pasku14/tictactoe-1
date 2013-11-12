require 'dm-core'
require 'dm-migrations'

class Juego
  include DataMapper::Resource
  property :id, Serial
  property :p_ganadas, Integer
  property :jugadas, Integer
  property :nombre, String
end

DataMapper.finalize


get '/juego' do
  @juego = Juego.all
  haml :juego
end
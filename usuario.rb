require 'dm-core'
require 'dm-migrations'

class Usuario
  include DataMapper::Resource
  property :id, Serial
  property :p_ganadas, Integer
  property :jugadas, Integer
  property :nombre, String
end

DataMapper.finalize

get '/usuarios' do
  @usuario = Usuario.all
  haml :usuario
end
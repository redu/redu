class Acquisition < ActiveRecord::Base
  belongs_to :acquired_by, :polymorphic => true
  belongs_to :course
  #TODO o polimorfico é acquired e o normal é user
  #TODO colocar verificacao para que nao hajam duplicatas (index?)
end

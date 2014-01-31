require 'mongoid'

class Tag
  include Mongoid::Document
  field :name,   type: String

  validates_uniqueness_of :name
  has_and_belongs_to_many :posts
end
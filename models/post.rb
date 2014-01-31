require 'mongoid'

class Post
  include Mongoid::Document
 
  field :title,   type: String
  field :content, type: String

  field :permalink, type: String, default: -> { make_permalink }
  has_and_belongs_to_many :tags

  def make_permalink
    title.downcase.gsub(/W/,'-').squeeze('-').chomp('-') if title
  end
end
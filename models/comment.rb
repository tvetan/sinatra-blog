require 'mongoid'

class Comment
  include Mongoid::Document
  include Mongoid::Versioning
  include Mongoid::Timestamps

  field :content, type: String

  belongs_to :user
  belongs_to :post
end
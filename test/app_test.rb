require 'mongoid'
require_relative './test_helper'

describe BlogApplication do
  describe "GET /" do
    it "redirects to /todos/new" do
      get "/"

      must_redirect_to "/todos/new"
    end
  end
end
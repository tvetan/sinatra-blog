module MiniTest::Assertions
  def assert_must_redirect_to(test, path)
    test.follow_redirect!
    current_path = test.last_request.path
    assert current_path == path, "Expected to be redirected to #{path}, current path #{current_path}"
  end

  def refute_must_redirect_to(test, path)
    test.follow_redirect!
    current_path = test.last_request.pathrefute current_path == path, "Expected not to be redirected to path"
  end
end

Object.infect_an_assertion :assert_must_redirect_to, :must_redirect_to, :reverse
Object.infect_an_assertion :refute_must_redirect_to, :wont_redirect_to, :reverse
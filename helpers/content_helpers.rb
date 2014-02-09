module ContentHelpers
  def cut_content(content)
    content[0..150] + (content.length > 150 ? "... " : " ")
  end
end
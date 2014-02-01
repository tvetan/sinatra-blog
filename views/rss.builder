xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title SITE_TITLE
    xml.link request.url.chomp request.path_info

    @posts.each do |post|
      xml.item do
        xml.title escape_html post.content
        xml.link "#{request.url.chomp request.path_info}/#{post.id}"
        xml.guid "#{request.url.chomp request.path_info}/#{post.id}"
      end
    end
  end
end
class GithubUsersWorker
  include Sidekiq::Worker
  require 'net/http'
  sidekiq_options queue: "high"

  def perform(username)
    user = User.new
    user_url = URI.parse("https://github.com#{username}")
    user_followers_url = URI.parse("https://github.com#{username}/followers")

    user_response = Net::HTTP.start(user_url.host, use_ssl: true) do |http|
      http.get user_url.request_uri
    end

    user_followers_response = Net::HTTP.start(user_followers_url.host, use_ssl: true) do |http|
      http.get user_followers_url.request_uri
    end


    user_html = Nokogiri::HTML(user_response.body)

    user_followers_html = Nokogiri::HTML(user_followers_response.body)
    user_followers_html.css('li.follow-list-item').each do |el|

      follower = el.css('h3.follow-list-name span a')[0]["href"]
      self.perform_async("#{follower}")
    end

    user_data_html = user_html.css("h1.vcard-names")

    user.full_name = user_data_html.children[1].children.text
    user.user_name = user_data_html.children[3].children.text
    user.save
    puts user
  end

end

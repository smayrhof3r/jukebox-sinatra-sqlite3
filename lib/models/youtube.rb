require "open-uri"
require "json"

API_KEY = "&key=AIzaSyCvx6X1mnvRfh9zMCuVplVyeAAwp5e_Ygg"
BASE_URL = 'https://youtube.googleapis.com/youtube/v3/search?maxResults=1&type=video&'
class Youtube
  attr_reader :watch_url, :embed_url
  def initialize(search_term)
    @url = "#{BASE_URL}"
    @search_term = search_term
    @res = ""
    @watch_url = ""
    @embed_url = ""
    fetch
  end

  private

  def get_json
    url = "#{@url}q=#{@search_term}#{API_KEY}"
    @res = URI.parse(url).open.string
    @res = JSON.parse(@res)
  end

  def youtube_link
    video_id = @res["items"].first["id"]["videoId"]
    watch = "https://www.youtube.com/watch?v="
    embed = "https://www.youtube.com/embed/"
    @watch_url = "#{watch}#{video_id}"
    @embed_url = "#{embed}#{video_id}"
  end

  def fetch
    get_json
    youtube_link
  end
end

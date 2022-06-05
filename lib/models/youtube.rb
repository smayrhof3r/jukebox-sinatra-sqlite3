require "open-uri"
require "json"

API_KEY = "&key=AIzaSyCvx6X1mnvRfh9zMCuVplVyeAAwp5e_Ygg"
BASE_URL = 'https://youtube.googleapis.com/youtube/v3/search?maxResults=5&type=video&'
class Youtube
  attr_reader :video_ids # :watch_url

  def initialize(search_term)
    @url = "#{BASE_URL}"
    @search_term = search_term
    @json = json
    @video_ids = video_ids_from_json
  end

  private

  def json
    url = "#{@url}q=#{@search_term}#{API_KEY}"
    json_parse = URI.parse(url).open.string
    JSON.parse(json_parse)
  end

  def video_ids_from_json
    @json["items"].map { |item| item["id"]["videoId"] }
  end

  def self.thumbnail(video_id)
    "https://img.youtube.com/vi/#{video_id}/0.jpg"
  end

  def self.embed_link(video_id)
    "https://www.youtube.com/embed/#{video_id}"
  end
end

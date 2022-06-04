require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
# require "better_errors"
require "sqlite3"
require_relative "./models/repo"

configure :development do
  # use BetterErrors::Middleware
  # BetterErrors.application_root = File.expand_path(__dir__)    # expand_path('..', __FILE__)
end

DB = SQLite3::Database.new(File.join(File.dirname(__FILE__), "db/jukebox.sqlite"))
repo = Repo.new(DB)

get "/" do
  @artists = repo.artists
  erb :home # Will render views/home.erb file (embedded in layout.erb)
end

get "/artists/:id" do
  @albums = repo.albums_by_artist_(params[:id].to_i)
  erb :albums # Will render views/home.erb file (embedded in layout.erb)
end

get "/albums/:id" do
  @tracks = repo.tracks_by_album_(params[:id].to_i)
  erb :tracks # Will render views/home.erb file (embedded in layout.erb)
end

get "/tracks/:id" do
  @track = repo.track_by_track_(params[:id].to_i)
  # binding.pry
  erb :track # Will render views/home.erb file (embedded in layout.erb)
end
# Then:
# 1. Create an artist page with all the albums. Display genres as well
# 2. Create an album pages with all the tracks
# 3. Create a track page with all the track info

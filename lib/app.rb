require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
# require "better_errors"
require "sqlite3"
require_relative "./models/repo"
require_relative "./models/youtube"

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

get "/tracks/update/:id" do
  @track = repo.track_by_track_(params[:id].to_i)
  @track["videos"] = nil
  @new_search = true
  erb :track
end

post "/tracks/update/:id" do
  @track = repo.track_by_track_(params[:id].to_i)
  videos = Youtube.new(params["keywords"])
  repo.replace_videos(params[:id].to_i, videos)
  redirect "/tracks/#{params[:id]}"
end

get "/tracks/:id" do
  @track = repo.track_by_track_(params[:id].to_i)
  if @track["videos"].nil? || @track["videos"].empty?
    videos = Youtube.new("song by #{@track["artist"]} #{@track["name"]}")
    repo.add_videos(params[:id].to_i, videos)
    @track = repo.track_by_track_(params[:id].to_i)
  end
  erb :track # Will render views/home.erb file (embedded in layout.erb)
end

get "/video/:video_id" do
  @video = Youtube.embed_link(params[:video_id])
  @track = repo.track_by_video_(params[:video_id])
  erb :track # Will render views/home.erb file (embedded in layout.erb)
end


# Then:
# 1. Create an artist page with all the albums. Display genres as well
# 2. Create an album pages with all the tracks
# 3. Create a track page with all the track info

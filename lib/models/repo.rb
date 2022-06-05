# Database queries for jukebox
class Repo
  attr_reader :artist, :album, :tracks

  def initialize(db)
    @db = db
  end

  def artists
    query = <<~SQL
      select id, name from artists
      order by name
    SQL

    @db.execute(query).to_h
  end

  def albums_by_artist_(id)
    query = <<~SQL
      select p.name as artist, a.id, a.title from albums a
      join artists p on p.id = a.artist_id
      where p.id = ?
      order by a.title
    SQL
    @albums = @db.execute(query, id)
    return [] if @albums.empty?

    @albums.map { |album| %w[artist id title].zip(album).to_h }
  end

  def tracks_by_album_(id)
    query = <<~SQL
      select t.id, t.name, p.name as artist, a.title as album, t.milliseconds, t.unit_price from tracks t
      join albums a on a.id = t.album_id
      join artists p on p.id = a.artist_id
      where a.id = ?
    SQL

    @tracks = @db.execute(query, id)
    return [] if @tracks.empty?

    @tracks.map { |track| %w[id name artist album duration price].zip(track).to_h }
  end

  def track_by_track_(id)
    query = <<~SQL
      select t.id, t.name, p.name as artist, a.title as album, t.milliseconds, t.unit_price from tracks t
      join albums a on a.id = t.album_id
      join artists p on p.id = a.artist_id
      where t.id = #{id}
    SQL

    track = %w[id name artist album duration price].zip(@db.execute(query).flatten).to_h

    videos = @db.execute("select video_id from videos v where v.track_id = #{id}").flatten
    track["videos"] = videos if videos
    track
  end

  def track_by_video_(id)

    query = <<~SQL
      select t.id, t.name, p.name as artist, a.title as album, t.milliseconds, t.unit_price from tracks t
      join albums a on a.id = t.album_id
      join artists p on p.id = a.artist_id
      join videos v on v.track_id = t.id
      where v.video_id = "#{id}"
      limit 1
    SQL

    track = %w[id name artist album duration price].zip(@db.execute(query).flatten).to_h
    videos = @db.execute("select video_id from videos v where v.track_id = #{track["id"]}").flatten
    track["videos"] = videos if videos
    track
  end

  def replace_videos(track_id, videos)
    @db.execute("DELETE FROM videos WHERE track_id = ?", track_id)
    add_videos(track_id, videos)
  end

  def add_videos(track_id, videos)
    insert_string = videos.video_ids.map { |video_id| "(#{track_id}, '#{video_id}')" }.join(",")
    @db.execute("INSERT INTO videos (track_id, video_id) values #{insert_string};")
  end
end

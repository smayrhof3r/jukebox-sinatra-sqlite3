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

    %w[id name artist album duration price].zip(@db.execute(query).flatten).to_h
  end
end

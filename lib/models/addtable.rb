require "sqlite3"
DB = SQLite3::Database.new(File.join(File.dirname(__FILE__), "../db/jukebox.sqlite"))
query = <<~SQL
  CREATE TABLE `videos` (
    `id`  INTEGER PRIMARY KEY AUTOINCREMENT,
    `track_id` INTEGER,
    `video_id` TEXT
  );
SQL
DB.execute(query)

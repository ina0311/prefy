require 'csv'

genre_name_files = Dir.glob("db/genre_names/*.csv")

genre_name_files.each do |file|
  CSV.foreach(file) do |row|
    Genre.create(name: row[0])
  end
end

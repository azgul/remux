require_relative 'playlist_detector'

require 'pathname'

class Remuxer
  def self.auto_remux(input_path, output_path)
    remux(PlaylistDetector.find_playlist(input_path), "#{output_path}/#{Pathname.new(input_path).basename}.mkv")
  end

  def self.remux(playlist_path, output_path)
    puts "remuxing #{playlist_path} -> #{output_path}"
    `mkvmerge "#{playlist_path}" -o "#{output_path}"`
  end
end
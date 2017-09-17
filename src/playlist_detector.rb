require 'json'
require 'awesome_print'
require 'pathname'

class PlaylistDetector
  ISO_MOUNT_PATH = "/media/remux"

  def self.detect_source_type(input_path)
    isos = Dir["#{input_path}/*.iso"]

    if isos.empty?
      return "extracted"
    elsif isos.length == 1
      return "iso"
    else
      raise "found more than one iso.. we didn't expect that"
    end
  end

  def self.find_playlist(input_path)
    mounted_path = input_path
    source_type = detect_source_type(input_path)

    if source_type.eql?('iso')
      mounted_path = mount_iso(input_path)
    end

    highest_duration = 0
    biggest_size = 0

    longest_playlist = nil
    largest_playlist = nil

    playlists_path = "#{mounted_path}/**/*.mpls"
    playlists = Dir[playlists_path]

    if playlists.empty?
      unmount_iso if source_type.eql?('iso')
      raise "no playlists found where expected! (#{playlists_path})"
    end

    playlists.each do |pl|
      playlist = JSON.parse(`mkvmerge -J "#{pl}"`)

      properties = playlist["container"]["properties"]

      chapters = properties["playlist_chapters"]
      duration = properties["playlist_duration"]
      size = properties["playlist_size"]
      files = properties["playlist_file"]

      next if files.length != files.uniq.length
      next if chapters.nil? || chapters < 2 && chapters < 90

      if duration > highest_duration
        highest_duration = duration
        longest_playlist = pl
      end

      if size > biggest_size
        biggest_size = size
        largest_playlist = pl
      end
    end

    if longest_playlist == largest_playlist
      duration = highest_duration / 1_000_000_000
      puts "best match: #{longest_playlist} (#{Time.at(duration).utc.strftime("%H:%M:%S")})"
      return longest_playlist
    else
      puts "longest playlist: #{longest_playlist}"
      puts "largest playlist: #{largest_playlist}"

      unmount_iso

      raise "no good candidate"
    end
  end

  def self.mount_iso(input_path)
    iso_path = Dir["#{input_path}/*.iso"].first
    puts "mounting iso #{iso_path} at #{ISO_MOUNT_PATH}"
    `mount -o loop #{iso_path} #{ISO_MOUNT_PATH}`

    if Dir["#{ISO_MOUNT_PATH}/BDMV/PLAYLIST/*.mpls"].empty?
      unmount_iso
      raise "failed mounting iso.. no playlists found"
    end

    return ISO_MOUNT_PATH
  end

  def self.unmount_iso
    puts "unmounting iso"
    `umount #{ISO_MOUNT_PATH}`
  end
end
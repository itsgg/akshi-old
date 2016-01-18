class MediaConverter
  @queue = :media_converter

  def self.perform(file_path)
    ext_name = File.extname(file_path)
    basename = file_path.chomp(ext_name)
    movie = FFMPEG::Movie.new(file_path)

    # TODO: Encode only till bitrates less than the source bitrates

    if Lesson::AUDIO_TYPE.include?(ext_name)
      # Transcode to differernt bitrates
      movie.transcode(basename + '_16.mp3', {:audio_bitrate => 16})
      movie.transcode(basename + '_32.mp3', {:audio_bitrate => 32})
      movie.transcode(basename + '_64.mp3', {:audio_bitrate => 64})
      movie.transcode(basename + '_128.mp3', {:audio_bitrate => 128})
    end

    if Lesson::VIDEO_TYPE.include?(ext_name)
      movie.screenshot("#{basename}_thumbnail.png", { :seek_time => 2 })
      # Transcode to differernt bitrates
      movie.transcode(basename + '_75.mp4', {:video_bitrate => 75})
      movie.transcode(basename + '_150.mp4', {:video_bitrate => 150})
    end

    # This file is checked to make sure the conversion completed
    FileUtils.touch("#{basename}.converted")
  end
end

require 'test_helper'

class MediaConverterTest < ActiveSupport::TestCase
  setup do
    current_dir = File.dirname(__FILE__)
    @uploads_path = File.join(current_dir, '..', 'fixtures', 'uploads')
    @audio_file = File.join(@uploads_path, 'test.mp3')
    @video_file = File.join(@uploads_path, 'test.m4v')
    # Delete any converted file if exists
    Dir.glob(File.join(@uploads_path, 'test_') + '*').each do |file|
      File.delete file
    end
    @status_file = File.join(@uploads_path, 'test.converted')
    File.delete @status_file if File.exists?(@status_file)
    @audio_bitrates = [16, 32, 64, 128]
    @video_bitrates = [75, 150]
  end

  test 'audio conversion' do
    MediaConverter.perform(@audio_file)
    @audio_bitrates.each do |bitrate|
      assert File.exists?(File.join(@uploads_path, "test_#{bitrate}.mp3"))
    end
    assert File.exists?(@status_file)
  end

  test 'Video conversion' do
    MediaConverter.perform(@video_file)
    @video_bitrates.each do |bitrate|
      assert File.exists?(File.join(@uploads_path, "test_#{bitrate}.mp4"))
    end
    assert File.exists?(@status_file)
  end
end

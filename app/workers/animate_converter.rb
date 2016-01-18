class AnimateConverter
  @queue = :animator_converter

  def self.perform(file_path)
    output_directory = File.dirname(file_path)
    # /system/hello.pdf => /system/hello
    basename = file_path.chomp(File.extname(file_path))
    if Docsplit::extract_images file_path, :output => output_directory
      FileUtils.touch("#{basename}.converted")
    end
  end
end
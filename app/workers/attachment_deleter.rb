class AttachmentDeleter
  @queue = :attachment_deleter

  def self.perform(file_path)
    if file_path.present?
      basename = file_path.chomp(File.extname(file_path))
      Dir.glob("#{basename}*").each { |f| File.delete(f) }
    end
  end
end

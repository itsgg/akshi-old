SRC_FILE_NAMES = ['Uploader.mxml', 'RtmpPublisher.mxml', 'FileReader.mxml']
INPUT_DIR = File.join(Rails.root, 'app', 'flash', 'src')
SRC_FILES = SRC_FILE_NAMES.map { |file_name| File.join(INPUT_DIR, file_name) }
OUTPUT_DIR = File.join(Rails.root, 'app', 'assets', 'flash')

namespace :flash do
  desc 'Compile flash source files'
  task :compile do
    SRC_FILES.each do |file|
      system "mxmlc #{file} -o #{File.join(OUTPUT_DIR, File.basename(file, '.mxml'))}.swf -compiler.source-path #{INPUT_DIR}"
    end
  end
end

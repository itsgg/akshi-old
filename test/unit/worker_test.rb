
UPLOADS_PATH = File.join(Rails.root, 'test', 'fixtures', 'uploads')
UPLOADS_TEST_PATH = File.join(Rails.root, 'test', 'fixtures', 'uploads_test')

class WorkerTest < ActiveSupport::TestCase
  setup do
    FileUtils.cp_r UPLOADS_PATH, UPLOADS_TEST_PATH
  end

  teardown do
    FileUtils.rm_r UPLOADS_TEST_PATH
  end

  def assert_document_conversion
    DocumentConverter.perform(File.join(UPLOADS_TEST_PATH, 'test.pdf'))
    assert File.exists?(File.join(UPLOADS_TEST_PATH, 'test_1.png'))
    assert File.exists?(File.join(UPLOADS_TEST_PATH, 'test.converted'))
  end

  test 'media converter' do
    MediaConverter.perform(File.join(UPLOADS_TEST_PATH, 'test.m4v'))
    assert File.exists?(File.join(UPLOADS_TEST_PATH, 'test_75.mp4'))
    assert File.exists?(File.join(UPLOADS_TEST_PATH, 'test_150.mp4'))
    assert File.exists?(File.join(UPLOADS_TEST_PATH, 'test.converted'))
  end

  test 'document converter' do
    assert_document_conversion
  end

  test 'AttachmentDeleter' do
    assert_document_conversion
    AttachmentDeleter.perform(File.join(UPLOADS_TEST_PATH, 'test.pdf'))
    assert !File.exists?(File.join(UPLOADS_TEST_PATH, 'test_1.png'))
    assert !File.exists?(File.join(UPLOADS_TEST_PATH, 'test.converted'))
  end
end

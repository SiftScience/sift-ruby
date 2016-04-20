module MockResponsesLoader
  def read_mock_response(filename)
    File.read(File.join(File.dirname(__FILE__), filename))
  end
end

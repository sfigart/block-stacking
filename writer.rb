class Writer
  
  def initialize(filename)
    @filename = filename
    clear_contents_of_file
  end
  
  def clear_contents_of_file
    File.open(@filename, 'w') {}
  end
  
  def write(text)
    File.open(@filename, 'a') {|f| f.write(text) }
  end
  
  def puts(text)
    File.open(@filename, 'a') {|f| f.puts(text) }
  end
end
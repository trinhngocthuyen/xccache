class Dir
  def self.prepare(dir)
    dir = Pathname(dir)
    dir.mkpath
    dir
  end
end

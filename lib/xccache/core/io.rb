class Dir
  def self.prepare(dir)
    dir = Pathname(dir)
    dir.mkpath
    dir
  end
end

class Pathname
  def symlink_to(dst)
    dst = Pathname(dst)
    dst.rmtree if dst.symlink?
    File.symlink(expand_path, dst)
  end
end

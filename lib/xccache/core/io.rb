class Dir
  def self.prepare(dir)
    dir = Pathname(dir)
    dir.mkpath
    dir
  end

  def self.create_tmpdir
    dir = Pathname(Dir.mktmpdir("xccache"))
    res = block_given? ? (yield dir) : dir
    dir.rmtree if block_given?
    res
  end
end

class Pathname
  def symlink_to(dst)
    dst = Pathname(dst)
    dst.rmtree if dst.symlink?
    File.symlink(expand_path, dst)
  end

  def copy(to: nil, to_dir: nil)
    dst = to || (Pathname(to_dir) / basename)
    FileUtils.copy_entry(self, dst)
    dst
  end
end

require "digest"

class String
  def c99extidentifier
    sub(/[^a-zA-Z0-9.]/, "_")
  end
end

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

  def self.git?(dir)
    XCCache::Sh.capture_output("git -C #{dir} rev-parse --git-dir") == ".git"
  end
end

class Pathname
  def symlink_to(dst)
    dst = Pathname(dst)
    dst.rmtree if dst.symlink?
    dst.parent.mkpath
    File.symlink(expand_path, dst)
  end

  def copy(to: nil, to_dir: nil)
    dst = to || (Pathname(to_dir) / basename)
    dst.rmtree if dst.exist? || dst.symlink?
    FileUtils.copy_entry(self, dst)
    dst
  end

  def checksum
    hasher = Digest::SHA256.new
    glob("**/*").reject { |p| p.directory? || p.symlink? }.sort.each do |p|
      p.open("rb") do |f|
        while (chunk = f.read(65_536)) # Read 64KB chunks
          hasher.update(chunk)
        end
      end
    end
    hasher.hexdigest[...8]
  end
end

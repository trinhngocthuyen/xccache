require_relative "base"

module XCCache
  class S3Storage < Storage
    def initialize(options = {})
      super
      @uri = options[:uri]
      @creds_path = Pathname(options[:creds_path] || "~/.xccache/s3.creds.json").expand_path
      creds = JSONRepresentable.new(@creds_path)
      @access_key_id = creds["access_key_id"]
      @secret_access_key = creds["secret_access_key"]
    end

    def pull
      s3_sync(src: @uri, dst: config.spm_repo_dir)
    end

    def push
      s3_sync(src: config.spm_repo_dir, dst: @uri)
    end

    private

    def s3_sync(src: nil, dst: nil)
      validate!
      UI.info("Syncing cache from #{src.to_s.bold} to #{dst.to_s.bold}...")
      env = {
        "AWS_ACCESS_KEY_ID" => @access_key_id,
        "AWS_SECRET_ACCESS_KEY" => @secret_access_key,
      }
      cmd = ["aws", "s3", "sync"]
      cmd << "--exact-timestamps" << "--delete"
      cmd << "--include" << "*.xcframework"
      cmd << "--include" << "*.macro"
      cmd << src << dst
      Sh.run(cmd, env: env)
    end

    def validate!
      if File.which("awsss").nil?
        raise GeneralError, "awscli is not installed. Please install it via brew: `brew install awscli`"
      end
      return unless @access_key_id.nil? || @secret_access_key.nil?
      raise GeneralError, <<~DESC
        Please ensure the credentials json at #{@creds_path}. Example:
        {
          "access_key_id": <ACCESS_KEY_ID>,
          "secret_access_key": <SECRET_ACCESS_KEY>
        }
      DESC
    end
  end
end

require 'objspace'
require 'zlib'
require 'fog'
require 'shellwords'
require 'tempfile'

module Debug
  class HeapDump
    include Interactor

    def call
      Tempfile.create('json.gz') do |io|
        Rails.logger.info 'dumping'
        IO.popen("gzip -9 -c > #{Shellwords.escape io.path}", 'w') do |gz|
          ObjectSpace.trace_object_allocations_start
          GC.start
          ObjectSpace.dump_all(output: gz)
          gz.close
        end
        io.rewind
        
        Rails.logger.info 'prepping'
        file = s3dir.files.new(
          key:    Time.current.strftime('logs/dump-%Y%m%d-%H%M%S.json.gz'),
          body:   io,
          public: false,
        )

        Rails.logger.info 'uploading'
        file.save
      end
    rescue => e
      Rails.logger.error("#{e.class.name}: #{e.message}")
      Rails.logger.error(e.backtrace.map(&:indent).join("\n"))
    end

    private

    def s3
      Fog::Storage.new({
        :provider                 => 'AWS',
        :aws_access_key_id        => ENV['AWS_ACCESS_KEY_ID'],
        :aws_secret_access_key    => ENV['AWS_SECRET_ACCESS_KEY'],
        :region                   => 'eu-west-1',
      })
    end

    def s3dir
      s3.directories.new(key: 'mezis-eu', locatin: 'eu-west-1')
    end

  end
end

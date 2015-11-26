# -*- encoding: utf-8 -*-

require 'json'
require 'digest/md5'

module Aliyun
  module OSS

    ##
    # Multipart upload/download structures
    #
    module Multipart

      ##
      # A multipart transaction. Provide the basic checkpoint methods.
      #
      class Transaction < Struct::Base

        include Logging

        attrs :id, :object, :bucket, :creation_time, :options

        def initialize(opts = {})
          super(opts)

          @mutex = Mutex.new
        end

        private
        # Persist transaction states to file
        def write_checkpoint(states, file)
          md5= Util.get_content_md5(states.to_json)

          @mutex.synchronize {
            File.open(file, 'w') {
              |f| f.write(states.merge(md5: md5).to_json)
            }
          }
        end

        # Load transaction states from file
        def load_checkpoint(file)
          states = {}

          @mutex.synchronize {
            states = JSON.load(File.read(file))
          }
          states.symbolize_keys!
          md5 = states.delete(:md5)

          fail CheckpointBrokenError, "Missing MD5 in checkpoint." unless md5
          unless md5 == Util.get_content_md5(states.to_json)
            fail CheckpointBrokenError, "Unmatched checkpoint MD5."
          end

          states
        end

        def get_file_md5(file)
          Digest::MD5.file(file).to_s
        end

      end # Transaction

      ##
      # A part in a multipart uploading transaction
      #
      class Part < Struct::Base

        attrs :number, :etag, :size, :last_modified

      end # Part

    end # Multipart
  end # OSS
end # Aliyun

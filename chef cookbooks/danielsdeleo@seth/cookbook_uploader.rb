
require 'set'
require 'rest_client'
require 'seth/exceptions'
require 'seth/ceth/cookbook_metadata'
require 'seth/digester'
require 'seth/cookbook_version'
require 'seth/cookbook/syntax_check'
require 'seth/cookbook/file_system_file_vendor'
require 'seth/util/threaded_job_queue'
require 'seth/sandbox'

class Seth
  class CookbookUploader

    attr_reader :cookbooks
    attr_reader :path
    attr_reader :opts
    attr_reader :rest
    attr_reader :concurrency

    # Creates a new CookbookUploader.
    # ===Arguments:
    # * cookbooks::: A Seth::CookbookVersion or array of them describing the
    #                cookbook(s) to be uploaded
    # * path::: A String or Array of Strings representing the base paths to the
    #           cookbook repositories.
    # * opts::: (optional) An options Hash
    # ===Options:
    # * :force  indicates that the uploader should set the force option when
    #           uploading the cookbook. This allows frozen CookbookVersion
    #           documents on the server to be overwritten (otherwise a 409 is
    #           returned by the server)
    # * :rest   A Seth::REST object that you have configured the way you like it.
    #           If you don't provide this, one will be created using the values
    #           in Seth::Config.
    # * :concurrency   An integer that decided how many threads will be used to
    #           perform concurrent uploads
    def initialize(cookbooks, path, opts={})
      @path, @opts = path, opts
      @cookbooks = Array(cookbooks)
      @rest = opts[:rest] || Seth::REST.new(seth::Config[:seth_server_url])
      @concurrency = opts[:concurrency] || 10
    end

    def upload_cookbooks
      # Syntax Check
      validate_cookbooks
      # generate checksums of cookbook files and create a sandbox
      checksum_files = {}
      cookbooks.each do |cb|
        Seth::Log.info("Saving #{cb.name}")
        checksum_files.merge!(cb.checksums)
      end

      checksums = checksum_files.inject({}){|memo,elt| memo[elt.first]=nil ; memo}
      new_sandbox = rest.post_rest("sandboxes", { :checksums => checksums })

      Seth::Log.info("Uploading files")

      queue = Seth::Util::ThreadedJobQueue.new

      checksums_to_upload = Set.new

      # upload the new checksums and commit the sandbox
      new_sandbox['checksums'].each do |checksum, info|
        if info['needs_upload'] == true
          checksums_to_upload << checksum
          Seth::Log.info("Uploading #{checksum_files[checksum]} (checksum hex = #{checksum}) to #{info['url']}")
          queue << uploader_function_for(checksum_files[checksum], checksum, info['url'], checksums_to_upload)
        else
          Seth::Log.debug("#{checksum_files[checksum]} has not changed")
        end
      end

      queue.process(@concurrency)

      sandbox_url = new_sandbox['uri']
      Seth::Log.debug("Committing sandbox")
      # Retry if S3 is claims a checksum doesn't exist (the eventual
      # in eventual consistency)
      retries = 0
      begin
        rest.put_rest(sandbox_url, {:is_completed => true})
      rescue Net::HTTPServerException => e
        if e.message =~ /^400/ && (retries += 1) <= 5
          sleep 2
          retry
        else
          raise
        end
      end

      # files are uploaded, so save the manifest
      cookbooks.each do |cb|
        save_url = opts[:force] ? cb.force_save_url : cb.save_url
        begin
          rest.put_rest(save_url, cb)
        rescue Net::HTTPServerException => e
          case e.response.code
          when "409"
            raise Seth::Exceptions::CookbookFrozen, "Version #{cb.version} of cookbook #{cb.name} is frozen. Use --force to override."
          else
            raise
          end
        end
      end

      Seth::Log.info("Upload complete!")
    end

    def worker_thread(work_queue)
    end

    def uploader_function_for(file, checksum, url, checksums_to_upload)
      lambda do
        # Checksum is the hexadecimal representation of the md5,
        # but we need the base64 encoding for the content-md5
        # header
        checksum64 = Base64.encode64([checksum].pack("H*")).strip
        timestamp = Time.now.utc.iso8601
        file_contents = File.open(file, "rb") {|f| f.read}
        # TODO - 5/28/2010, cw: make signing and sending the request streaming
        headers = { 'content-type' => 'application/x-binary', 'content-md5' => checksum64, "accept" => 'application/json' }
        if rest.signing_key
          sign_obj = Mixlib::Authentication::SignedHeaderAuth.signing_object(
                                                                             :http_method => :put,
                                                                             :path        => URI.parse(url).path,
                                                                             :body        => file_contents,
                                                                             :timestamp   => timestamp,
                                                                             :user_id     => rest.client_name
                                                                             )
          headers.merge!(sign_obj.sign(OpenSSL::PKey::RSA.new(rest.signing_key)))
        end

        begin
          Seth::HTTP::Simple.new(url, :headers=>headers).put(url, file_contents)
          checksums_to_upload.delete(checksum)
        rescue Net::HTTPServerException, Net::HTTPFatalError, Errno::ECONNREFUSED, Timeout::Error, Errno::ETIMEDOUT, SocketError => e
          error_message = "Failed to upload #{file} (#{checksum}) to #{url} : #{e.message}"
          error_message << "\n#{e.response.body}" if e.respond_to?(:response)
          Seth::ceth.ui.error(error_message)
          raise
        end
      end
    end

    def validate_cookbooks
      cookbooks.each do |cb|
        syntax_checker = Seth::Cookbook::SyntaxCheck.for_cookbook(cb.name, @user_cookbook_path)
        Seth::Log.info("Validating ruby files")
        exit(1) unless syntax_checker.validate_ruby_files
        Seth::Log.info("Validating templates")
        exit(1) unless syntax_checker.validate_templates
        Seth::Log.info("Syntax OK")
        true
      end
    end

  end
end
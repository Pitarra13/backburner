require 'delegate'

module Echelon
  class Connection < SimpleDelegator
    class BadURL < RuntimeError; end

    # Echelon::Connection.setup("beanstalk://localhost")
    def self.setup(url)
      @connection ||= self.new(url)
    end

    attr_accessor :url, :beanstalk

    def initialize(url)
      @url = url
      connect!
    end

    # Sets the delegator object to the underlying beanstalk connection
    # self.put(...)
    def __getobj__
      __setobj__(@beanstalk)
      super
    end

    protected

    # Connects to a beanstalk queue
    def connect!
      @beanstalk ||= Beanstalk::Pool.new(beanstalk_addresses)
    end

    # Returns the beanstalk queue addresses
    def beanstalk_addresses
      uris = self.url.split(/[\s,]+/)
      uris.map {|uri| beanstalk_host_and_port(uri)}
    end

    # Returns a host and port based on the uri_string given
    def beanstalk_host_and_port(uri_string)
      uri = URI.parse(uri_string)
      raise(BadURL, uri_string) if uri.scheme != 'beanstalk'
      "#{uri.host}:#{uri.port || 11300}"
    end
  end # Connection
end # Echelon
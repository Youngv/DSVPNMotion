class Api < AppDelegate
  IP_API_ENDPOINT = "https://api.ipify.org"

  class << self
    attr_accessor :ip

    def self.getIPAddress
      Dispatch::Queue.concurrent.async do  
        url = NSURL.URLWithString IP_API_ENDPOINT
        request = NSURLRequest.requestWithURL url
        session = NSURLSession.sharedSession
        task = session.dataTaskWithRequest(request, completionHandler: ->(data, response, error) {
          @ip = NSString.alloc.initWithData data, encoding: NSUTF8StringEncoding
        })
        task.resume
      end
    end
  end
end

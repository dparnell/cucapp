require 'thin'

module Encumber
  # TODO: automatically guess this value
  build_dir = Dir.glob('Build/*.build').first
  raise 'Can not find build directory' if build_dir.nil?
  raise 'Can not determine Cappuccino application name' if build_dir.match(/Build\/(.*)\.build/).nil?
  app_name = $1
  
  if File.exists?('Build/Debug')
    mode = 'Debug'
  else
    mode = 'Release'
  end
  APP_DIRECTORY = "Build/#{mode}/#{app_name}"

  raise "Can not locate built application directory: #{APP_DIRECTORY}" if !File.exists?(APP_DIRECTORY)
  
  CUCUMBER_BUNDLE_DIR = File.join(File.dirname(__FILE__), 'Build', 'Debug', 'Cucumber')

  CUCUMBER_REQUEST_QUEUE = EM::Queue.new
  CUCUMBER_RESPONSE_QUEUE = EM::Queue.new

  MAIN_THREAD = Thread.current

  class DeferrableBody
    include EventMachine::Deferrable

    def call(body)
      body.each do |chunk|
        @body_callback.call(chunk)
      end
    end

    def each(&blk)
      @body_callback = blk
    end
  end

  class CucumberAdapter
    AsyncResponse = [-1, {}, []].freeze
  
    def call(env)    
      if env['REQUEST_METHOD']=='GET'      
        body = DeferrableBody.new
      
        # Get the headers out there asap, let the client know we're alive...
        EM.next_tick do
          env['async.callback'].call [200, {'Content-Type' => 'text/plain'}, body]
      
          CUCUMBER_REQUEST_QUEUE.pop { |req|
            body.call [req.to_json]
            body.succeed
          }
        end
      
        AsyncResponse
      else
        CUCUMBER_RESPONSE_QUEUE.push env
        result = {:result => :ok}
      
        body = [result.to_json]
        [
          200,
          { 'Content-Type' => 'text/plain' },
          body
        ]       
      end
    end
  end

  class CucumberIndexAdapter
    def call(env)
      html = File.read(File.join(APP_DIRECTORY, 'index.html'))
    
      html.gsub!(/<title>(.*)<\/title>/) do
        "<title>#{$1} - Cucumber</title>"
      end
    
      html.gsub!(/<\/body>/) do
        <<-END_OF_JS
          <script type="text/javascript">
              var cucumber = new CFBundle("/Cucumber/Bundle/");
              cucumber.load(true);
          </script>
        </body>
  END_OF_JS
      end
    
      body = [html]
      [
        200,
        {
          'Content-Type' => 'text/html',
        },
        body
      ]
    end
  end
  
  html = File.read(File.join(APP_DIRECTORY, 'index.html'))

  html.gsub!(/<title>(.*)<\/title>/) do
    "<title>#{$1} - Cucumber</title>"
  end

  html.gsub!(/<\/body>/) do
    <<-END_OF_JS
      <script type="text/javascript">
          var cucumber = new CFBundle("/Cucumber/Bundle/");
          cucumber.load(true);
      </script>
    </body>
END_OF_JS
  end
  
  File.open(File.join(APP_DIRECTORY, 'cucumber.html'), 'w') {|f| f.write(html) }

  Thread.new{
    EM.run {
      cucumber = Rack::URLMap.new(
        '/cucumber' => CucumberAdapter.new,
        '/Cucumber/Bundle' => Rack::Directory.new(CUCUMBER_BUNDLE_DIR),
        '/' => Rack::Directory.new(APP_DIRECTORY)
      )
    
      Thin::Server.start('0.0.0.0', 3000) {
        run(cucumber)
#        puts "RESTARTING main thread"
        Encumber::MAIN_THREAD.wakeup
      }
    }
  }
  Thread.stop
end
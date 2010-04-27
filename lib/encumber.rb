require 'enumerator' 
require 'json'
require 'nokogiri'
require 'server'

module Encumber

  class GUI
    def initialize(timeout_in_seconds=4)
      @timeout     = timeout_in_seconds
    end

    def command(name, *params)
      raw = params.shift if params.first == :raw
      command = { :name => name, :params => params }

      puts "COMMAND = #{command.inspect}"
      th = Thread.current
      response = nil
      CUCUMBER_REQUEST_QUEUE.push(command)
      CUCUMBER_RESPONSE_QUEUE.pop { |result|
        response = result
        th.wakeup
      }
      Thread.stop
      
      response['rack.input'].read
    end

    def find(xpath)
      dom_for_gui.search(xpath)
    end
	
    def restart
      begin
        @gui.quit
      rescue EOFError
        # no-op
      end

      sleep 3

      yield if block_given?

      launch

    end

    def launch
      # TODO: make this work across more operating systems
      system("open http://localhost:3000/cucumber.html")      
    end
    
    def quit
      command 'terminateApp'
    end

    def dump
      xml = command 'outputView'
#      puts xml     
      xml
    end

    def press(xpath)
      command 'simulateTouch', 'viewXPath', xpath
    end

    # Nokogiri XML DOM for the current Brominet XML representation of the GUI
    def dom_for_gui
      @dom = Nokogiri::XML self.dump
    end

    # Idiomatic way to say wait_for_element

    def wait_for xpath
      wait_for_element xpath
    end

    # Wait for element.  Returns an array of elements that match the
    # xpath, or nil if nothing matches the xpath and the timeout
    # period has expired.
    # 
    # Note that there's no need to sleep between polls.  At most, we
    # can only poll about every other second, because it takes that
    # long to request and receive the Brominet GUI XML.

    def wait_for_element xpath
      start_time_for_wait = Time.now

      loop do
        elements                = dom_for_gui.search(xpath)

        return elements unless elements.empty?

        # Important: get the elapsed time AFTER getting the gui and
        # evaluating the xpath.
        elapsed_time_in_seconds = Time.now - start_time_for_wait

        return nil if elapsed_time_in_seconds >= @timeout
      end
    end

    def type_in_field text, xpath
      command('setText', 
              'text',      text,
              'viewXPath', xpath)
      sleep 1
    end

    # swipe to the right
    def swipe xpath
      command('simulateSwipe',  
              'viewXPath', xpath)
    end

    # swipe to the left
    def swipe_left xpath
      command('simulateLeftSwipe',  
              'viewXPath', xpath)
    end

    def swipe_and_wait xpath
      swipe xpath
      sleep 1
    end

    def swipe_left_and_wait xpath
      swipe_left xpath
      sleep 1
    end

    def tap xpath
      press xpath
    end

    def tap_and_wait xpath
      press xpath
      sleep 1
    end

  end
end

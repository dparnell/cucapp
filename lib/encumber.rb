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

#      puts "command = #{command.inspect}"
      
      th = Thread.current
      response = nil
      CUCUMBER_REQUEST_QUEUE.push(command)
      CUCUMBER_RESPONSE_QUEUE.pop { |result|
        response = result
        th.wakeup
      }
      Thread.stop
      
      data = response['rack.input'].read
      
      if data && !data.empty?
        obj = JSON.parse(data)
        
        if obj["error"]
          raise obj["error"]
        else
          obj["result"]
        end
      else
        nil
      end
    end

    def find(xpath)
      dom_for_gui.search(xpath)
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

    def id_for_element(xpath)
      elements = dom_for_gui.search(xpath+"/id")
      raise "element not found: #{xpath}" if elements.empty?
      elements.first.inner_text.to_i
    end
    
    def press(xpath)
#      puts "elements = #{elements.inspect}"
      result = command 'simulateTouch', id_for_element(xpath)
      
      raise "View not found: #{xpath}" if result!='OK'
    end

    # Nokogiri XML DOM for the current Brominet XML representation of the GUI
    def dom_for_gui
      @dom = Nokogiri::XML self.dump
    end

    def wait_for xpath
      wait_for_element xpath
    end

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
      command('setText', id_for_element(xpath), text)
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

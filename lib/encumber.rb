require 'json'
require 'nokogiri'
require 'server'
require 'launchy'

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
      startTime = Time.now
      sleep @timeout
      raise "Command timed out" if Time.now-startTime>=@timeout
      
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
      sleep 0.2 # there seems to be a timing issue. This little hack fixes it.
      Launchy.open("http://localhost:3000/cucumber.html")      
      
      until command('launched') == "YES" do
        # do nothing
      end
      
      sleep 1
    end
    
    def quit
      command 'terminateApp'
      sleep 0.2
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
    
    def select_from(value_to_select, xpath)
      result = command 'selectFrom', value_to_select, id_for_element(xpath)
      
      raise "Could not select #{value_to_select} in #{xpath} " + result if result != "OK"
    end
    
    def select_menu(menu_item)
      result = command 'selectMenu', id_for_element("\\CPMenu")
      
      raise "Could not select #{menu_item} from the menu" if result != "OK"
    end
    
    def fill_in(value, xpath)
      type_in_field value, xpath
    end
    
    def find_in(value, xpath)
      result = command "findIn", value, id_for_element(xpath)
      
      raise "Could not find #{value} in #{xpath}" if result != "OK"
      
      result == "OK"
    end
    
    def text_for(xpath)
      result = command "textFor", id_for_element(xpath)
      
      raise "Could not find text for element #{xpath}" if result == "__CUKE_ERROR__"
      
      result
    end
    
    def double_click(value, xpath)
      command 'doubleClick', id_for_element(xpath)
      
      raise "Could not double click #{xpath}" if result != "OK"
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
      command('setText', text, id_for_element(xpath))
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

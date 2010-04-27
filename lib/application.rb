require 'encumber'
require 'rexml/document'

class Application
  class ExpectationFailed < RuntimeError
  end

  attr_reader :warning_text
  attr_reader :gui

  def initialize
    @gui = Encumber::GUI.new
    @gui.launch
  end

  def reset
    @gui.command 'restoreDefaults'
  end

  def dismiss_warning
    @warning_text = ''
    xml = @gui.dump
    doc = REXML::Document.new xml

    xpath = '//UIAlertView'
    warning = REXML::XPath.match(doc, xpath).first
    raise ExpectationFailed unless warning

    xpath = '//UIAlertView/subviews/UILabel/text'
    @warning_text = REXML::XPath.match(doc, xpath)[1].text

    @gui.press '//UIThreePartButton'
  end

  def restart
  end

end

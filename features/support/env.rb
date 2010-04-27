$: << File.join(File.dirname(__FILE__), '/../../lib')

require 'application.rb'

module AppHelper

  def app
    @app ||= Application.new
  end

end

World(
      AppHelper
      )

Before do
  app.reset
end


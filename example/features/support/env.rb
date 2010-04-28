$: << File.join(File.dirname(__FILE__), '..', '..' ,'..')

require 'cucapp.rb'

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

After do
  app.quit
end

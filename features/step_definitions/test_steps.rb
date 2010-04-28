Given /^the application is running$/ do
  windows = app.gui.wait_for "//CPButton[title='Press Me']"
  
  raise "Application didn't start" if windows.nil?
end

When /^I press the "([^\"]*)" button$/ do |arg1|
  app.gui.press "//CPButton[title='#{arg1}']"
end

Then /^the button should no longer have the title "([^\"]*)"$/ do |arg1|
  raise "It didn't change" if !app.gui.find("//CPButton[title='#{arg1}']").empty?
end

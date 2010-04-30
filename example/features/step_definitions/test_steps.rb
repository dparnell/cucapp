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

Given /^a new calculator window$/ do
  app.gui.command "newCalculator"
end

Then /^the result area should contain "([^\"]*)"$/ do |arg1|
  raise "Text area didn't contain '#{arg1}'" if app.gui.wait_for("//CPWindow[title='Calculator']//CPTextField[objectValue='#{arg1}']").nil?
end


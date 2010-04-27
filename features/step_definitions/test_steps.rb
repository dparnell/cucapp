Given /^the application is running$/ do
  app.gui.wait_for '//CPWindow'
  
  puts app.gui.dump
end

When /^I press the "([^\"]*)" button$/ do |arg1|
  app.gui.press "//CPButton[title='#{arg1}']"
end

Then /^the button should no longer have the title "([^\"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

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
  while !app.gui.find("//CPWindow[title='Calculator']").empty?
    app.gui.closeWindow "//CPWindow[title='Calculator']"
  end
  
  app.gui.command "newCalculator"
end

Then /^the result area should contain "([^\"]*)"$/ do |arg1|
  raise "Text area didn't contain '#{arg1}'" if app.gui.find("//CPWindow[title='Calculator']//CPTextField[objectValue='#{arg1}']").empty?
end

When /^I input "([^\"]*)" in the textfield$/ do |arg1|
  app.gui.fill_in arg1, "//CPTextField"
end

Then /^the textfield should have the text "([^\"]*)"$/ do |arg1|
  value = app.gui.text_for("//CPTextField")
  raise "ERROR: #{arg1} does not equal #{value}" if arg1 != value
end

Then /^the textfield with tag "([^\"]*)" should have the text "([^\"]*)"$/ do |arg1, arg2|
  value = app.gui.text_for("//CPTextField[tag='#{arg1}']")
  raise "ERROR: #{arg2} does not equal #{value}" if arg2 != value
end

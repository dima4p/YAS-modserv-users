require File.dirname(__FILE__) + '/spec_helper.rb'

module MailerSpecHelper
  private

    def read_fixture(action)
      IO.read("#{::FIXTURES_PATH}/mailers/notifier/#{action}")
    end
end

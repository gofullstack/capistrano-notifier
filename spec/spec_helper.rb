require 'timecop'

RSpec.configure do |config|
  config.around :each do |example|
    Timecop.freeze 2012, 1, 1 do
      example.run
    end
  end
end

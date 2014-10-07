require 'rspec'
require 'guard/rspec'

rspec_major_version = RSpec::Version::STRING.to_i

RSpec.configure do |config|
  if rspec_major_version < 3
    config.color_enabled = true
    config.treat_symbols_as_metadata_keys_with_true_values = true
  else
    config.color = true
  end
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

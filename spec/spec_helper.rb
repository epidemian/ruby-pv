RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!
  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed
end

module ConsoleGroupHelpers
  def silence_examples_output
    before do
      $stdout = File.open(File::NULL, 'w')
    end
    after do
      $stdout = STDOUT
    end
  end
end

module ConsoleExampleHelpers
  def mock_term_width(width)
    allow(IO.console).to receive(:winsize) { [42, width] }
  end
end

RSpec.configure do |config|
  config.extend ConsoleGroupHelpers
  config.include ConsoleExampleHelpers
end

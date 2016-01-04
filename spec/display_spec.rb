require 'pv'

# rubocop:disable Metrics/LineLength

RSpec.describe 'pv progress display' do
  it 'shows progress bar when running a loop of known size' do
    expect {
      4.times.pv {}
    }.to output_many(
      "Progress: 0/4 ▕                                                                ▏\r",
      "Progress: 1/4 ▕████████████████                                                ▏\r",
      "Progress: 2/4 ▕████████████████████████████████                                ▏\r",
      "Progress: 3/4 ▕████████████████████████████████████████████████                ▏\r",
      "Progress: 4/4 ▕████████████████████████████████████████████████████████████████▏\r",
      "                                                                                \r",
    ).to_stdout
  end

  it 'cleans progress bar even if loop terminates early' do
    expect {
      4.times.pv { |n| break if n == 2 }
    }.to output_many(
      "Progress: 0/4 ▕                                                                ▏\r",
      "Progress: 1/4 ▕████████████████                                                ▏\r",
      "Progress: 2/4 ▕████████████████████████████████                                ▏\r",
      "                                                                                \r",
    ).to_stdout
  end

  it 'shows animated progress indicator when running a loop of unknown size' do
    expect {
      5.times.to_enum.pv {}
    }.to output_many(
      "Progress: 0/unknown ▕▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▏\r",
      "Progress: 1/unknown ▕▖▘▗▝ ▖▘▗▝ ▖▘▗▝ ▖▘▗▝ ▖▘▗▝ ▖▘▗▝ ▖▘▗▝ ▖▘▗▝ ▖▘▗▝ ▖▘▗▝ ▖▘▗▝ ▖▘▗▏\r",
      "Progress: 2/unknown ▕ ▝▖ ▚ ▝▖ ▚ ▝▖ ▚ ▝▖ ▚ ▝▖ ▚ ▝▖ ▚ ▝▖ ▚ ▝▖ ▚ ▝▖ ▚ ▝▖ ▚ ▝▖ ▚ ▝▖▏\r",
      "Progress: 3/unknown ▕ ▗▘ ▞ ▗▘ ▞ ▗▘ ▞ ▗▘ ▞ ▗▘ ▞ ▗▘ ▞ ▗▘ ▞ ▗▘ ▞ ▗▘ ▞ ▗▘ ▞ ▗▘ ▞ ▗▘▏\r",
      "Progress: 4/unknown ▕▘▖▝▗ ▘▖▝▗ ▘▖▝▗ ▘▖▝▗ ▘▖▝▗ ▘▖▝▗ ▘▖▝▗ ▘▖▝▗ ▘▖▝▗ ▘▖▝▗ ▘▖▝▗ ▘▖▝▏\r",
      "Progress: 5/unknown ▕▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▌ ▐  ▏\r",
      "                                                                                \r",
    ).to_stdout
  end

  it 'lets code inside loop print to stdout without clobbering its output' do
    expect {
      (1..4).pv.each do |n|
        puts 'Hello from second iteration!' if n == 2
        (puts '4th...'; print 'A '; print 'weird '; print "line!\n") if n == 4
      end
    }.to output_many(
      "Progress: 0/4 ▕                                                                ▏\r",
      "Progress: 1/4 ▕████████████████                                                ▏\r",
      # Blank line to clear the progress bar before printing user output.
      "                                                                                \r",
      "Hello from second iteration!\n",
      # Re-print previous progress after printing a line to avoid progress bar
      # from disappearing if iteration takes too long.
      "Progress: 1/4 ▕████████████████                                                ▏\r",
      "Progress: 2/4 ▕████████████████████████████████                                ▏\r",
      "Progress: 3/4 ▕████████████████████████████████████████████████                ▏\r",
      "                                                                                \r",
      "4th...\n",
      "Progress: 3/4 ▕████████████████████████████████████████████████                ▏\r",
      "                                                                                \r",
      "A weird line!\n",
      "Progress: 3/4 ▕████████████████████████████████████████████████                ▏\r",
      "Progress: 4/4 ▕████████████████████████████████████████████████████████████████▏\r",
      "                                                                                \r",
    ).to_stdout
  end

  def output_many(*expected)
    output(expected.join)
  end
end

class Pv
  include Enumerable

  def initialize(enum)
    @enum = enum
  end

  def each
    return to_enum unless block_given?

    self.progress = 0

    hijack_stdout

    display_progress

    @enum.each do |item|
      val = yield item
      self.progress += 1
      display_progress
      val
    end
  ensure
    # Run on ensure block to raised StopIterations don't mess up the display.
    clear_progress
    restore_stdout
  end

  private

  attr_accessor :progress

  def total
    @enum.size
  end

  def unknown_total?
    total.nil? || total == Float::INFINITY
  end

  def display_progress
    if unknown_total?
      total_text = 'unknown'
      progress_text = progress.to_s
    else
      total_text = total.to_s
      progress_text = progress.to_s.rjust(total_text.size)
    end
    l_bar = "Progress: #{progress_text}/#{total_text} ▕"
    r_bar = "▏"
    bar_size = term_width - l_bar.size - r_bar.size
    bar = draw_progress_bar(bar_size)
    line = "#{l_bar}#{bar}#{r_bar}\r"
    @original_stdout.print line
    @progress_displayed = true
  end

  def clear_progress
    return unless @progress_displayed
    @original_stdout.print(" " * term_width + "\r")
    @progress_displayed = false
  end

  def term_width
    # TODO use real term size.
    80
  end

  FRAC_CHARS = " ▏▎▍▌▋▊▉"

  def draw_progress_bar(bar_size)
    return draw_unknown_progress_bar(bar_size) if unknown_total?
    copleted_size, remainder = (progress.to_f / total * bar_size).divmod(1)

    rem_char =
      progress == total ? '' : FRAC_CHARS[(FRAC_CHARS.size * remainder).floor]

    completed = '█' * copleted_size
    uncompleted = ' ' * (bar_size - copleted_size - rem_char.size)

    "#{completed}#{rem_char}#{uncompleted}"
  end

  UNKNOWN_PROGRESS_FRAMES = [
    "▐  ▌ ",
    "▖▘▗▝ ",
    " ▝▖ ▚",
    " ▗▘ ▞",
    "▘▖▝▗ ",
  ].map(&:chars)

  def draw_unknown_progress_bar(bar_size)
    frame = UNKNOWN_PROGRESS_FRAMES[progress % UNKNOWN_PROGRESS_FRAMES.size]
    frame.cycle.take(bar_size).join
  end

  # Hijacks $stdout so user can still print stuff while showing the progressbar.
  def hijack_stdout
    @original_stdout = $stdout
    $stdout = PvAwareStdout.new do |data|
      clear_progress
      @original_stdout.write(data)
      display_progress if data.end_with?("\n")
    end
  end

  def restore_stdout
    $stdout = @original_stdout
  end

  # TODO make this respond to everything STDOUT responds to.
  class PvAwareStdout
    def initialize(&writer)
      @writer = writer
    end

    def write(data)
      @writer.call(data)
    end
  end
end

module Enumerable
  # TODO Add non-monkey-patching alternative (refinements maybe?)
  def pv(&blk)
    pv = Pv.new(self)
    if blk
      pv.each(&blk)
    else
      pv
    end
  end
end

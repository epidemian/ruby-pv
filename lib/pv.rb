require 'io/console'
require 'stringio'

class Pv
  include Enumerable

  attr_accessor :progress

  def initialize(enum)
    @enum = enum
  end

  def each
    return to_enum unless block_given?
    # TODO: don't display progress unless $stdout.tty?

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
    clear_progress
    restore_stdout
  end

  def write_to_stdout(data)
    clear_progress
    @original_stdout.write(data)
    display_progress if data.end_with?("\n")
  end

  private

  def total
    @enum.size
  end

  def unknown_total?
    total.nil? || total == Float::INFINITY
  end

  def display_progress
    l_bar = "Progress: #{formatted_numeric_progress} ▕"
    r_bar = '▏'
    bar_size = term_width - l_bar.size - r_bar.size
    bar = draw_progress_bar(bar_size)
    line = "#{l_bar}#{bar}#{r_bar}\r"
    @original_stdout.print line
    @progress_displayed = true
  end

  def clear_progress
    return unless @progress_displayed
    @original_stdout.print(' ' * term_width + "\r")
    @progress_displayed = false
  end

  def term_width
    if @original_stdout.tty?
      @original_stdout.winsize[1]
    else
      80
    end
  end

  def formatted_numeric_progress
    if unknown_total?
      total_text = 'unknown'
      progress_text = progress.to_s
    else
      total_text = total.to_s
      progress_text = progress.to_s.rjust(total_text.size)
    end
    "#{progress_text}/#{total_text}"
  end

  def draw_progress_bar(bar_size)
    if unknown_total?
      draw_unknown_progress_bar(bar_size)
    else
      draw_known_progress_bar(bar_size)
    end
  end

  FRAC_CHARS = ' ▏▎▍▌▋▊▉'

  def draw_known_progress_bar(bar_size)
    completed_size, remainder = (progress.to_f / total * bar_size).divmod(1)

    rem_char =
      progress == total ? '' : FRAC_CHARS[(FRAC_CHARS.size * remainder).floor]

    completed = '█' * completed_size
    uncompleted = ' ' * (bar_size - completed_size - rem_char.size)

    "#{completed}#{rem_char}#{uncompleted}"
  end

  UNKNOWN_PROGRESS_FRAMES = [
    '▐  ▌ ',
    '▖▘▗▝ ',
    ' ▝▖ ▚',
    ' ▗▘ ▞',
    '▘▖▝▗ ',
  ].map(&:chars)

  def draw_unknown_progress_bar(bar_size)
    frame = UNKNOWN_PROGRESS_FRAMES[progress % UNKNOWN_PROGRESS_FRAMES.size]
    frame.cycle.take(bar_size).join
  end

  # Hijacks $stdout so user can still print stuff while showing the progressbar.
  def hijack_stdout
    @original_stdout = $stdout
    $stdout = PvAwareStdout.new(self)
  end

  def restore_stdout
    $stdout = @original_stdout
  end

  # Extend StringIO so all output IO methods are supported and defined in terms
  # of write(). It does *not* respect the Liskov substitution principle.
  class PvAwareStdout < StringIO
    def initialize(pv)
      super()
      @pv = pv
    end

    def write(data)
      @pv.write_to_stdout(data)
    end
  end
end

Enumerable.module_eval do
  # TODO: Add non-monkey-patching alternative (refinements maybe?)
  def pv(&blk)
    pv = Pv.new(self)
    if blk
      pv.each(&blk)
    else
      pv
    end
  end
end

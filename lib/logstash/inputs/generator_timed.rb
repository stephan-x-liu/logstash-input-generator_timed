# encoding: utf-8
require "logstash/inputs/threadable"
require "logstash/namespace"
require "socket" # for Socket.gethostname

# Generate random log events.
#
# The general intention of this is to test performance of plugins.
#
# An event is generated first
class LogStash::Inputs::GeneratorTimed < LogStash::Inputs::Threadable
  config_name "generator_timed"
  milestone 1

  default :codec, "plain"

  # The message string to use in the event.
  #
  # If you set this to 'stdin' then this plugin will read a single line from
  # stdin and use that as the message string for every event.
  #
  # Otherwise, this value will be used verbatim as the event message.
  config :message, :validate => :string, :default => "Hello world!"

  config :lines_per_second, :validate => :number, :default => 7000

  # The lines to emit, in order. This option cannot be used with the 'message'
  # setting.
  #
  # Example:
  #
  #     input {
  #       generator {
  #         lines => [
  #           "line 1",
  #           "line 2",
  #           "line 3"
  #         ]
  #         # Emit all lines 3 times.
  #         count => 3
  #       }
  #     }
  #
  # The above will emit "line 1" then "line 2" then "line", then "line 1", etc...
  config :lines, :validate => :array

  # Set how long messages should be generated for
  #
  # The default, 0, means unlimited number of seconds
  config :seconds, :validate => :number, :default => 0

  public
  def register
    @curr = 0
    @host = Socket.gethostname
    @seconds = @seconds.first if @seconds.is_a?(Array)
  end # def register

  def run(queue)
    @lines = [@message] if @lines.nil?
    while !finished? && (@seconds <= 0 || @curr < @seconds)
      time_elapsed = generate_events(queue)
      @curr += 1
      puts "Events generated: " + (@curr * @lines_per_second).to_s
      puts "Event generation time: " + (time_elapsed).to_s
      if time_elapsed < 1
        sleep(1 - time_elapsed)
      end
    end # loop

    if @codec.respond_to?(:flush)
      @codec.flush do |event|
        decorate(event)
        event["host"] = @host
        queue << event
      end
    end
  end # def run

  def generate_events(queue)
    number = 0
    beginning_time = Time.now
    while number < @lines_per_second
      @lines.each do |line|
        @codec.decode(line.clone) do |event|
          decorate(event)
          event["host"] = @host
          event["sequence"] = @lines_per_second * @curr + number
          queue << event
          number += 1
        end
      end
    end
    end_time = Time.now
    return end_time - beginning_time
  end


  public
  def teardown
    @codec.flush do |event|
      decorate(event)
      event["host"] = @host
      queue << event
    end
    finished
  end # def teardown
end # class LogStash::Inputs::GeneratorTimed
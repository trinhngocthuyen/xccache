require "parallel"

class Array
  def parallel_map(options = {})
    # By default, use in_threads (IO-bound tasks)
    default = {}
    default[:in_threads] = Parallel.processor_count unless options.key?(:in_processes)
    Parallel.map(self, { **default, **options }) { |x| yield x if block_given? }
  end
end

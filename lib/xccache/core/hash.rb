class Hash
  def deep_merge(other, &block)
    dup.deep_merge!(other, &block)
  end

  def deep_merge!(other, uniq: true, &block)
    merge!(other) do |key, this_val, other_val|
      result = if this_val.is_a?(Hash) && other_val.is_a?(Hash)
                 this_val.deep_merge(other_val, &block)
               elsif this_val.is_a?(Array) && other_val.is_a?(Array)
                 this_val + other_val
               elsif block_given?
                 block.call(key, this_val, other_val)
               else
                 other_val
               end
      uniq && result.is_a?(Array) ? result.uniq : result
    end
  end
end

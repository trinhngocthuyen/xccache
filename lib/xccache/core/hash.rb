class Hash
  def deep_merge(other, uniq_block: nil, &block)
    dup.deep_merge!(other, uniq_block: uniq_block, &block)
  end

  def deep_merge!(other, uniq_block: nil, &block)
    merge!(other) do |key, this_val, other_val|
      result = if this_val.is_a?(Hash) && other_val.is_a?(Hash)
                 this_val.deep_merge(other_val, uniq_block: uniq_block, &block)
               elsif this_val.is_a?(Array) && other_val.is_a?(Array)
                 this_val + other_val
               elsif block_given?
                 block.call(key, this_val, other_val)
               else
                 other_val
               end
      next result if uniq_block.nil? || !result.is_a?(Array)
      result.reverse.uniq(&uniq_block).reverse # prefer updates
    end
  end
end

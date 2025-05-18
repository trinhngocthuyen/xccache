class Hash
  def deep_merge(other, uniq_block: nil, sort_block: nil, &block)
    dup.deep_merge!(other, uniq_block: uniq_block, sort_block: sort_block, &block)
  end

  def deep_merge!(other, uniq_block: nil, sort_block: nil, &block)
    merge!(other) do |key, this_val, other_val|
      result = if this_val.is_a?(Hash) && other_val.is_a?(Hash)
                 this_val.deep_merge(other_val, uniq_block: uniq_block, sort_block: sort_block, &block)
               elsif this_val.is_a?(Array) && other_val.is_a?(Array)
                 this_val + other_val
               elsif block_given?
                 block.call(key, this_val, other_val)
               else
                 other_val
               end

      # uniq by block, prefer updates
      result = result.reverse.uniq(&uniq_block).reverse if uniq_block && result.is_a?(Array)
      result = result.sort_by(&sort_block) if sort_block && result.is_a?(Array)
      result
    end
  end
end

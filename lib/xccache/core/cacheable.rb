module XCCache
  module Cacheable
    def cacheable(*method_names)
      method_names.each do |method_name|
        const_get(__cacheable_module_name).class_eval do
          define_method(method_name) do |*args, **kwargs|
            @_cache ||= {}
            @_cache[method_name] ||= {}
            @_cache[method_name][args.hash | kwargs.hash] ||=
              method(method_name).super_method.call(*args, **kwargs)
          end
        end
      end
    end

    def __cacheable_module_name
      "#{name}_Cacheable".gsub(':', '_')
    end

    def self.included(base)
      base.extend(self)

      module_name = base.send(:__cacheable_module_name)
      remove_const(module_name) if const_defined?(module_name)
      base.prepend(const_set(module_name, Module.new))
    end
  end
end

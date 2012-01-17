module PryStackExplorer
  class WhenStartedHook

    def caller_bindings(binding_stack)
      target = binding_stack.last

      if binding.of_caller(6).eval('__method__') == :pry
        drop_number = 8
      else
        drop_number = 7
      end

      bindings = binding.callers.drop(drop_number)

      # Use the binding returned by #of_caller if possible (as we get
      # access to frame_type).
      # Otherwise stick to the given binding (target).
      if !PryStackExplorer.bindings_equal?(target, bindings.first)
        bindings.shift
        bindings.unshift(target)
      end

      bindings
    end

    def call(binding_stack, options, _pry_)
      options = {
        :call_stack    => true,
        :initial_frame => 0
      }.merge!(options)

      return if !options[:call_stack]

      if options[:call_stack].is_a?(Array)
        bindings = options[:call_stack]

        if bindings.empty? || !bindings.all? { |v| v.is_a?(Binding) }
          raise ArgumentError, ":call_stack must be an array of bindings"
        end
      else
        bindings = caller_bindings(binding_stack)
      end

      #binding_stack.replace [bindings[initial_frame]]
      PryStackExplorer.create_and_push_frame_manager bindings, _pry_, :initial_frame => options[:initial_frame]
      #PryStackExplorer.frame_manager(_pry_).set_binding_index_safely(initial_frame)
    end
  end
end

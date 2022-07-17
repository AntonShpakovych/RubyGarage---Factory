class Factory
  class << self
    def new(*attributes, &block)
      if attributes.first.is_a? String
        return const_set(attributes.shift, create_class(*attributes, &block))
      end

      return create_class(*attributes, &block)
    end

    def create_class(*attributes, &block)
      Class.new do
        attr_accessor(*attributes)

        define_method :initialize do |*parameters|
          raise(ArgumentError, "Expected: #{attributes.length}, given: #{parameters.length}") if parameters.length != attributes.length
          attributes.each_with_index { |property, index| instance_variable_set "@#{property}", parameters[index] }
        end

        class_eval &block if block_given?

        define_method :members do
          attributes
        end

        define_method :[]= do |attribute, value|
          instance_variable_set((attribute.is_a?(Integer) ? instance_variables[attribute] : "@#{attribute}"), value)
        end

        define_method :[] do |attribute|
          instance_variable_get(attribute.is_a?(Integer) ? instance_variables[attribute] : "@#{attribute}")
        end

        def to_a
          instance_variables.map { |value| instance_variable_get(value) }
        end

        def each(&block)
          to_a.each(&block)
        end

        def each_pair(&block)
          members.zip(to_a).each(&block)
        end

        def eql?(other)
          self.class == other.class && self.to_a == other.to_a
        end
        alias :== :eql?

        def dig(*keys)
          keys.inject(self) { |data, key| data[key] if data }
        end

        def select(&block)
          to_a.select(&block)
        end

        def values_at(*indexes)
          to_a.values_at(*indexes)
        end

        def length
          instance_variables.length
        end
        alias :size :length
      end
    end
  end
end

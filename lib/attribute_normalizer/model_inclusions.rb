module AttributeNormalizer

  def self.included(base)
    base.extend ClassMethods
  end


  module ClassMethods

    def normalize_attributes(*attributes, &block)
      options = attributes.extract_options!

      attributes.each do |attribute|

        define_method "normalize_#{attribute}" do |value|
          normalized = if block_given? && !value.blank?
            yield(value)
          elsif !options[:with].nil? && !value.blank?
            unless AttributeNormalizer.configuration.normalizers.has_key?(options[:with])
              raise AttributeNormalizer::MissingNormalizer.new("No normalizer was found for #{options[:with]}")
            end
            AttributeNormalizer.configuration.normalizers[options.delete(:with)].call(value, options)
          else
            value.is_a?(String) ? value.strip : value
          end
          normalized.nil? || (normalized.is_a?(String) && normalized == '') ? nil : normalized
        end
        self.send :private, "normalize_#{attribute}"

        define_method "#{attribute}=" do |value|
          super(self.send(:"normalize_#{attribute}", value))
        end

      end

    end
    alias :normalize_attribute :normalize_attributes

  end

end
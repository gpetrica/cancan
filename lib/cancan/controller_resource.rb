module CanCan
  # Used internally to load and authorize a given controller resource.
  class ControllerResource # :nodoc:
    def initialize(controller, name, parent = nil, options = {})
      raise ImplementationRemoved, "The :class option has been renamed to :resource for specifying the class in CanCan." if options.has_key? :class
      @controller = controller
      @name = name
      @parent = parent
      @options = options
    end
    
    def model_class
      resource_class = @options[:resource]
      if resource_class.nil?
        @name.to_s.camelize.constantize rescue @name.to_s.split("_").map {|p| p.camelize}.join("::").constantize
      elsif resource_class.kind_of? String
        resource_class.constantize
      else
        resource_class # likely a symbol
      end
    end
    
    def find(id)
      self.model_instance ||= base.find(id)
    end
    
    def build(attributes)
      if base.kind_of? Class
        self.model_instance ||= base.new(attributes)
      else
        self.model_instance ||= base.build(attributes)
      end
    end
    
    def model_instance
      @controller.instance_variable_get("@#{@name}")
    end
    
    def model_instance=(instance)
      @controller.instance_variable_set("@#{@name}", instance)
    end
    
    private
    
    def base
      @parent ? @parent.model_instance.send(@name.to_s.pluralize) : model_class
    end
  end
end

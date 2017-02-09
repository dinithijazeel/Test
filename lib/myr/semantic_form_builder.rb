module Myr
  class SemanticFormBuilder < FormtasticBootstrap::FormBuilder

    def input(method, options = {})
      # Suppress label by default
      options[:label] = false if options[:label].nil?
      # Add method (field name) to classes
      options[:input_html] = inject_classes(options[:input_html], method.to_s)
      # Call
      super(method, options)
    end

    # TODO: Implement as custom input
    def file_widget(method, options = {})
      label = method.to_s.humanize
      if object.send(method).blank?
        display_value = "No #{label}"
      else
        display_value = object.send(method).file.filename
      end
      label = template.content_tag(:label, label, class: 'control-label')
      label = template.content_tag(:span, label, class: 'form-label')
      icon = '<i class="fa fa-upload"></i>'.html_safe
      widget = icon << file_field(method, options)
      widget = template.content_tag(:span, widget, class: 'btn btn-default btn-file')
      widget = template.content_tag(:label, widget, class: 'input-group-btn')
      input = template.tag(:input, class: 'form-control', type: 'text', readonly: true, value: display_value)
      input_group = template.content_tag(:div, widget << input, class: 'input-group')
      input_group = template.content_tag(:span, input_group, class: 'form-wrapper')
      template.content_tag(:div, label << input_group, class: 'file input form-group')
    end


    def action(method, options = {})
      # TODO: Add confirm option
      if !options.nil? && options[:type]
        classes = "btn btn-#{options[:type]}"
      else
        classes = 'btn btn-primary'
      end
      options[:button_html] = inject_classes(options[:button_html], classes)
      super(method, options)
    end

    private

    def inject_classes(options, classes)
      classes.join!(' ') if classes.is_a?(Array)
      if options.nil?
        options = {class: classes}
      else
        if options[:class]
          options[:class] << " #{classes}"
        else
          options[:class] = classes
        end
      end
      print "#{options.to_s}\n"
      options
    end

    # JS_FOR_COMBOSELECT = "<script type='text/javascript'>
    #                         $(document).ready(function() {
    #                           $('#%s').comboselect();
    #                         });
    #                       </script>"
    #
    # private
    #
    # def comboselect_input(method, options)
    #   (JS_FOR_COMBOSELECT % "#{sanitized_object_name}_#{generate_association_input_name(method)}") << select_input(method, options)
    # end
  end
end

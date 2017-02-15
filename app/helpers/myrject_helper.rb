#
# module ApplicationHelper
#
module MyrjectHelper

  def finput(f, method, options = {})
    # Suppress label by default
    options[:label] = false if options[:label].nil?
    # Add method (field name) to classes
    options[:input_html] = {class: method.to_s}
    # Call
    f.input(method, options)
  end

  def myrject(type, options = {}, &block)
    Myrject::Myrject.render(type, options, self, &block)
  end
  #
  # Forms
  #
  def myr_form(record_or_name_or_array, *args, &block)
    options = args.extract_options!
    if options[:html]
      class_names = (defined?(options[:html][:class]) && options[:html][:class]) ? options[:html][:class].split(" ") : []
      class_names << 'myriander'
      options[:html][:class] = class_names.compact.join(" ")
    else
      options[:html] = {
        :class => 'myriander'
      }
    end
    semantic_form_for(record_or_name_or_array, *(args << options), &proc)
  end

  def myr_card(record, *args, &block)
    yield new Myrject::RecordCard(record)
  end

  def myr_modal(*args, &block)
    yield new Myrject::Modal
  end

  def form_header(content, &block)
    # TODO: Some unobtrusive form header
    # if block_given?
    #   content_tag(:div, capture(&block), class: 'form-header')
    # else
    #   content_tag(:div, content, class: 'form-header')
    # end
  end

  def form_body(&block)
    if block_given?
      content_tag(:div, capture(&block), class: 'form-body')
    else
      content_tag(:div, content, class: 'form-body')
    end
  end

  def form_footer(&block)
    if block_given?
      content_tag(:div, capture(&block), class: 'form-footer')
    else
      content_tag(:div, content, class: 'form-footer')
    end
  end

  def field(label, content = '', options = {}, &block)
    # Move options to proper place if we have a block
    if content.is_a?(Hash)
      options = content
    end
    # Set class
    if options[:class]
      classes = options[:class]
    else
      classes = nil
    end
    # Create label
    label = content_tag(:label, label, class: 'control-label')
    label = content_tag(:span, label, class: 'form-label')
    # Get content
    if block_given?
      content = capture(&block)
    end
    # Do we tag it?
    if options[:tag]
      content = content_tag(:span, content, class: options[:tag])
    end
    content = content_tag(:div, content, class: 'form-control-static')
    # Wrap if we were given a class
    if classes
      content_tag(:div, label << content, class: classes)
    else
      label << content
    end
  end


  def button_link(name = nil, options = nil, html_options = nil, &block)
    # Calculate classes
    if !html_options.nil? && html_options[:type]
      classes = "btn btn-#{html_options[:type]}"
      html_options.delete(:type)
    else
      classes = 'btn btn-default'
    end
    # Insert classes
    if html_options.nil?
      html_options = {class: classes}
    else
      if html_options[:class]
        html_options[:class] << " #{classes}"
      else
        html_options[:class] = classes
      end
    end
    # Add confirmations
    if html_options[:confirm]
      html_options[:data] = {
        confirm: html_options[:confirm]
      }
      html_options.delete(:confirm)
    end
    link_to(name, options, html_options, &block)
  end
  #
  # Table Elements
  #
  def table(*args, &block)
    classes = 'table table-condensed'
    classes << " #{args[0][:class]}" unless args[0].nil?
    content_tag(:table, capture(&block), class: classes)
  end
  #
  # Grid Elements
  #
  def row(options = {}, &block)
    content_tag(:div, capture(&block), class: 'row')
  end

  def col(options = {}, &block)
    classes = []
    classes << "col-md-#{options[:md]}" if defined?(options[:md])
    content_tag(:div, capture(&block), class: classes)
  end
end

module Myrject

  class Myrject
    attr_reader :blocks

    def initialize(type, options, view_context = nil)
      # Set view context for class if missing and given
      @view_context = view_context if @view_context.nil? && view_context
      @type = type
      @options = options
      @blocks = {}
      @buffer = ''
      extend module_name unless uses_template?
    end

    def execute(&block)
      buffer(yield self)
      self
    end

    def uses_template?
      [:view_panel].include?(@type)
    end

    def module_name
      "Myrject::#{@type.to_s.classify}".constantize
    end

    def capture_block(&block)
      @view_context.capture(&block)
    end

    def fetch_block(name)
      if defined?(@blocks[name])
        @blocks[name]
      else
        ''
      end
    end

    def add_block(name, content)
      name = name.to_sym if name.is_a? String
      @blocks[name] = content
    end

    def buffer(content)
      @buffer << content unless content.nil?
    end

    def div(content, css_class = nil, attributes = {})
      tag(:div, content, css_class, attributes)
    end

    def tag(tag_type, content, css_class = nil, attributes = {})
      if css_class.is_a?(Hash)
        attributes = css_class
        css_class = nil
      end
      content = fetch_block(content) if content.is_a? Symbol
      content_tag(tag_type, content, attributes.merge(class: css_class))
    end

    def content_tag(name, content_or_options_with_block = nil, options = nil, escape = false, &block)
      @view_context.content_tag(name, content_or_options_with_block, options, escape, &block)
    end

    def self.render(type, options, view_context = nil, &block)
      Myrject.new(type, options, view_context).execute(&block).render
    end

    def render
      if uses_template?
        @blocks.each do |label, content_block|
          @view_context.content_for label, content_block, :flush => true
        end
        @view_context.render "application/myrjects/#{@type.to_s}"
      else
        # @buffer.html_safe
      end
    end

    def method_missing(name, *args, &block)
      if block.nil?
        add_block(name, args[0])
      else
        add_block(name, capture_block(&block))
      end
    end
  end

  module Card
    def render
      actions = div(:action, 'panel-heading-buttons')
      title = div(:title, 'panel-title')
      header = div(actions << title, 'panel-heading')
      body = div(:body, 'panel-content')
      div(header << body, 'panel panel-default data-display')
    end
  end

  module Modal
    def render
      modal_classes = 'modal-dialog modal-lg'
      show_close = @options[:show_close].nil? || @options[:show_close]
      # show_close = false
      if show_close
        top_close_button = tag(:span, '&times;', 'aria-hidden' => 'true')
        top_close_button = tag(:button, top_close_button, 'close cancel', {'aria-label' => 'Close', type: 'button', data: {dismiss: 'modal'}})
        bottom_close_button = tag(:button, 'Close', 'btn btn-default', {type: 'button', data: {dismiss: 'modal'}})
      else
        top_close_button = ''
        bottom_close_button = ''
      end
      title = tag(:h2, :title, 'modal-title')
      header = div(top_close_button << title, 'modal-header')
      body = div(:body, 'modal-body')
      footer = div(bottom_close_button << ' ' << fetch_block(:footer), 'modal-footer')
      content = div(header << body << footer, 'modal-content')
      modal = div(content, modal_classes)
    end
  end

  module Table
    def render
      header = tag(:thead, :thead)
      body = tag(:tbody, :tbody)
      footer = tag(:tfooter, :tfooter)
      tag(:table, header << body << footer, 'table table-condensed')
    end

    def header(options = {}, &block)
      @blocks[:thead] = tag(:tr, Myrject.render(:table_head, @view_context, &block))
    end
  end

  module TableHead
    def render
      tag(:tr, header << body << footer, 'table table-condensed')
    end
    def cell(content, options = {}, &block)
      tag(:th, content)
    end
  end

end

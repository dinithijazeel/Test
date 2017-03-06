require 'render_anywhere'

class Pdf
  include RenderAnywhere

  class RenderingController < RenderAnywhere::RenderingController
    def initialize
      super
      prepend_view_path "app/views/tenants/#{Conf.tenant}"
    end
  end

  def self.generate (view, options = {})
    generator = self.new
    generator.generate_pdf(view, options)
  end

  def self.merge(filepath, components)
    pdf = CombinePDF.new
    components.each do |component|
      pdf << CombinePDF.load(component) unless component.nil?
    end
    pdf.save filepath
  end

  def generate_pdf (view, options)
    # Set helpers
    set_render_anywhere_helpers('ApplicationHelper')
    set_render_anywhere_helpers('MyrjectHelper')
    # Do we have instance vars?
    options[:instance_vars].each do |name, value|
      set_instance_variable(name, value)
    end if options[:instance_vars]
    # Render HTML
    html = render(
      :template      => view,
      :layout        => options[:layout] || 'pdf',
    )
    # Create PDF stream from HTML
    pdf = WickedPdf.new.pdf_from_string(
      html,
      :encoding      => 'UTF-8',
      :background    => true,
      :page_size     => 'Letter',
      :no_pdf_compression => false,
      :margin =>  {
        :top         => 0,
        :bottom      => 0,
        :left        => 0,
        :right       => 0
      }
    )
    # Save as file
    save_path = Tempfile.new(['wicked_pdf-', '.pdf'])
    File.open(save_path, 'wb') { |file| file << pdf }
    # Return path
    save_path
  end


end

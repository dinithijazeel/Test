#
# module ApplicationHelper
#
module ApplicationHelper
  def markdown(text)
    # Configure
    options = {
      :filter_html         => true,
      :hard_wrap           => true,
      :link_attributes     => { :rel => 'nofollow', :target => '_blank' },
      :space_after_headers => true,
      :fenced_code_blocks  => true,
    }
    extensions = {
      :autolink                     => true,
      :superscript                  => true,
      :disable_indented_code_blocks => true,
    }
    # Set up
    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    # Render
    markdown.render(text).html_safe
  end

  def fa(name, add_space = false)
    case name
    when 'alias'
      name = 'eye'
    when 'auth'
      name = 'sign-in'
    when 'contact'
      name = 'user'
    when 'contacts'
      name = 'users'
    when 'customer'
      name = 'user'
    when 'customers'
      name = 'users'
    when 'datasheet'
      name = 'file'
    when 'destroy'
      name = 'times'
    when 'invoices', 'invoice'
      name = 'briefcase'
    when 'products', 'product'
      name = 'shopping-cart'
    when 'profile'
      name = 'user'
    when 'proposals', 'proposal'
      name = 'file-pdf-o'
    when 'upload'
      name = 'arrow-circle-up'
    when 'vendors'
      name = 'industry'
    end
    fa = "<i class=\"fa fa-#{name}\"></i>"
    fa += '&nbsp;' if add_space
    fa.html_safe
  end

  def quantity(amount)
    if amount.nil?
      "0.00"
    else
      "#{number_with_precision(amount, :precision => 2, :delimiter => ',')}".html_safe
    end
  end

  def unit_price(amount)
    if amount.nil?
      "$ 0.00"
    else
      num = "$ #{number_with_precision(amount, :precision => 4, :delimiter => ',')}".html_safe
    end
  end

  def money(amount)
    if amount.nil?
      "$ 0.00"
    else
      "$ #{number_with_precision(amount, :precision => 2, :delimiter => ',')}".html_safe
    end
  end

  def phone(numbers)
    unless numbers.blank?
      numbers.gsub!(/\D/, '')
      if numbers.to_s.length <= 10
        number_to_phone(numbers, :area_code => true)
      else
        "#{number_to_phone(numbers.to_s[0..9], :area_code => true)} x#{numbers.to_s[10..20]}"
      end
    end
  end

  def states
    [
      ['United States', [
        ['Alabama', 'AL'],
        ['Alaska', 'AK'],
        ['Arizona', 'AZ'],
        ['Arkansas', 'AR'],
        ['California', 'CA'],
        ['Colorado', 'CO'],
        ['Connecticut', 'CT'],
        ['Delaware', 'DE'],
        ['District of Columbia', 'DC'],
        ['Florida', 'FL'],
        ['Georgia', 'GA'],
        ['Hawaii', 'HI'],
        ['Idaho', 'ID'],
        ['Illinois', 'IL'],
        ['Indiana', 'IN'],
        ['Iowa', 'IA'],
        ['Kansas', 'KS'],
        ['Kentucky', 'KY'],
        ['Louisiana', 'LA'],
        ['Maine', 'ME'],
        ['Maryland', 'MD'],
        ['Massachusetts', 'MA'],
        ['Michigan', 'MI'],
        ['Minnesota', 'MN'],
        ['Mississippi', 'MS'],
        ['Missouri', 'MO'],
        ['Montana', 'MT'],
        ['Nebraska', 'NE'],
        ['Nevada', 'NV'],
        ['New Hampshire', 'NH'],
        ['New Jersey', 'NJ'],
        ['New Mexico', 'NM'],
        ['New York', 'NY'],
        ['North Carolina', 'NC'],
        ['North Dakota', 'ND'],
        ['Ohio', 'OH'],
        ['Oklahoma', 'OK'],
        ['Oregon', 'OR'],
        ['Pennsylvania', 'PA'],
        ['Puerto Rico', 'PR'],
        ['Rhode Island', 'RI'],
        ['South Carolina', 'SC'],
        ['South Dakota', 'SD'],
        ['Tennessee', 'TN'],
        ['Texas', 'TX'],
        ['Utah', 'UT'],
        ['Vermont', 'VT'],
        ['Virginia', 'VA'],
        ['Washington', 'WA'],
        ['West Virginia', 'WV'],
        ['Wisconsin', 'WI'],
        ['Wyoming', 'WY']]],
      ['Canada', [
        ['Alberta', 'AB'],
        ['British Columbia', 'BC'],
        ['Manitoba', 'MB'],
        ['New Brunswick', 'NB'],
        ['Newfoundland and Labrador', 'NL'],
        ['Nova Scotia', 'NS'],
        ['Northwest Territories', 'NT'],
        ['Nunavut', 'NU'],
        ['Ontario', 'ON'],
        ['Prince Edward Island', 'PE'],
        ['Quebec', 'QC'],
        ['Saskatchewan', 'SK'],
        ['Yukon', 'YT']]],
    ]
  end

  def countries
    [
      ['United States', 'United States'],
      ['Canada', 'Canada'],
    ]
  end

  def filename(string)
    string.gsub(/[^\- 0-9a-z]/i, '')
  end
end

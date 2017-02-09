class ProductsProposal < Bom
    def datasheet_index
      line_items.select { |li| !li.product.datasheet.blank? }
    end
end

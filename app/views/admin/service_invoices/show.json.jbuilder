json.extract! @invoice, :id
json.pdf invoice_url(@invoice, format: :pdf)

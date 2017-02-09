window.search =

  # Default search

  defaultSearch: (search_url)->
    new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value')
      queryTokenizer: Bloodhound.tokenizers.whitespace
      # prefetch: "#{contacts_path}/?prefetch",
      remote:
        url: "#{search_url}/?q=%QUERY"
        wildcard: '%QUERY'
    )

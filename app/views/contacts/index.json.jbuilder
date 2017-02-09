json.array!(@contacts) do |contact|
  json.partial! 'contact', locals: {contact: contact}
end

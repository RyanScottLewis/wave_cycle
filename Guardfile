guard :bundler do
  watch('Gemfile')
end

guard 'rails', server: :puma do
  watch('Gemfile.lock')
  watch(%r{^(config|lib)/.*})
end

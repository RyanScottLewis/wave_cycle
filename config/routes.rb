WaveCycle::Application.routes.draw do
  root 'waves#new'
  resources 'waves' do
    collection do
      match 'generate', via: [:get, :post]
    end
  end
end

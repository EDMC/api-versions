Dummy::Application.routes.draw do
  api vendor_string: "myvendor" do
    version 1 do
      cache as: 'v1' do
        resources :bar
      end
    end

    version 2 do
      cache as: 'v2' do
        resources :foo
        inherit from: 'v1'
      end
    end

    version 3 do
      inherit from: 'v2'

      namespace :nests do
        resources :nested
      end
    end
  end

  api vendor_string: 'myvendor', path: '' do
    version 1 do
      cache as: 'v1' do
        resources :baz
      end
    end
  end

  get '*a' => 'errors#not_found'
end

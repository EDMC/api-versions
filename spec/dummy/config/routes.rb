Dummy::Application.routes.draw do
  api vendor_string: "myvendor" do
    version 1 do
      cache as: 'v1' do
        resources :bar
      end
    end

    version 2 do
      resources :foo
      inherit from: 'v1'
    end
  end
end

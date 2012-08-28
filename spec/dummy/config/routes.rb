Dummy::Application.routes.draw do
  namespace :api do
    default_api_version   1
    api_vendor            "myvendor"

    constraints api_version_check(:version => 1) do
       scope :module => :v1 do
         cache_resources :as => :v1 do
          resources :bar
        end
       end
    end

  # Version 2 of the API has everything in Version 1, plus my_new_resource
  # Version 2 will cache this entire package of resources
    constraints api_version_check(:version => 2) do
       scope :module => :v2 do
         cache_resources :as => :v2 do
           resources :foo
           inherit_resources :from => :v1
        end
       end
    end
  end
end

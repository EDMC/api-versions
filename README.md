API-Versions
================
If you have multiple versions of an API in your Rails app, it is not very DRY to include the same resources over and over again.
In your Gemfile:

	gem "api-versions", "~> 0.0.4"
	
In your routes.rb file:

	namespace :api do
	  default_api_version 	1   			 # If no API version is specified in the Accept header, this is what will be used.
	  api_vendor 			"myvendor"   	 # For HTTP Accept Header application/vnd.myvendor+json;version=1
  
	   constraints api_version_check(:version => 1) do
	     scope :module => :v1 do 
	       cache_resources :as => :v1 do
	         resources :authorizations, :only => [ :create ]
	       end
	     end
	  end
  
	  constraints api_version_check(:version => 2) do
	     scope :module => :v2 do 
	       inherit_resources :from => :v1
	     end
	  end 
	end

rake routes outputs:

	    api_authorizations GET    /api/authorizations(.:format)          api/v1/authorizations#index
	                       POST   /api/authorizations(.:format)          api/v1/authorizations#create
	 new_api_authorization GET    /api/authorizations/new(.:format)      api/v1/authorizations#new
	edit_api_authorization GET    /api/authorizations/:id/edit(.:format) api/v1/authorizations#edit
	     api_authorization GET    /api/authorizations/:id(.:format)      api/v1/authorizations#show
	                       PUT    /api/authorizations/:id(.:format)      api/v1/authorizations#update
	                       DELETE /api/authorizations/:id(.:format)      api/v1/authorizations#destroy
	                       GET    /api/authorizations(.:format)          api/v2/authorizations#index
	                       POST   /api/authorizations(.:format)          api/v2/authorizations#create
	                       GET    /api/authorizations/new(.:format)      api/v2/authorizations#new
	                       GET    /api/authorizations/:id/edit(.:format) api/v2/authorizations#edit
	                       GET    /api/authorizations/:id(.:format)      api/v2/authorizations#show
	                       PUT    /api/authorizations/:id(.:format)      api/v2/authorizations#update
	                       DELETE /api/authorizations/:id(.:format)      api/v2/authorizations#destroy

Then the client simply sets the Accept header "application/vnd.myvendor+json;version=1". If no version is specified, the default version you set will be assumed.  You'll of course still need to copy all of your controllers over, even if they haven't changed from version to version.  At least you'll remove a bit of the mess in your routes file.

A more complicated example
--------------------------
	namespace :api do
	  default_api_version 	1
	  api_vendor 		 	"myvendor"
  
	  constraints api_version_check(:version => 1) do
	     scope :module => :v1 do 
	       cache_resources :as => :v1 do
	        resources :authorizations, :only => [ :create ]
	        resources :foo
	        resources :bar
	      end
	     end
	  end
  
	# Version 2 of the API has everything in Version 1, plus my_new_resource
	# Version 2 will cache this entire package of resources
	  constraints api_version_check(:version => 2) do
	     scope :module => :v2 do 
	       cache_resources :as => :v2 do 
	         resources :my_new_resource
	         inherit_resources :from => :v1
	      end
	     end
	  end
  
	# Version 3 of the API has everything in API Version 2, and by
	# virtue of API Version 2 having everything in Version 1, Version 3
	# also has everything in Version 1.
	
	  constraints api_version_check(:version => 3) do
	     scope :module => :v3 do 
	        inherit_resources :from => :v2
	     end
	  end

	end

License
=======
Copyright (c) 2012 Erich Menge

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
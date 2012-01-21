API-Versions
================
If you have multiple versions of an API, it is not very DRY to include the same resources over and over again.  Instead, in your routes.rb file:

	include ApiVersions
	has_common_resources

Further down...

	namespace :api do
	  self.api_version = 1 # If no API version is specified in the Accept header, this is what will be used.
	  self.vendor = "myvendor" # For HTTP Accept Header application/vnd.myvendor+json;version=1
  
	  constraints ApiVersionCheck.new(:version => 1) do
	     scope :module => :v1 do 
	       cache_resources :as => :v1 do
	         resources :authorizations, :only => [ :create ]
	       end
	     end
	  end
  
	  constraints ApiVersionCheck.new(:version => 2) do
	     scope :module => :v2 do 
	       inherit_resources :from => :v1
	     end
	  end 
	end

In your Gemfile
	gem 'api-versions'

License
=======
Copyright (c) 2012 Erich Menge

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
API-Versions [![Build Status](https://secure.travis-ci.org/erichmenge/api-versions.png)](http://travis-ci.org/erichmenge/api-versions)
======================================================================================================================================

If you have multiple versions of an API in your Rails app, it is not very DRY to include the same resources over and over again.

Also, URL resources shouldn't change. Instead, API versions should be specified in the headers. The api-versions gem provides a nice DSL for this.

In your Gemfile:

  gem "api-versions", "~> 0.1.0"

In your routes.rb file:

    api vendor_string: "myvendor", default_version: 1 do      # You can leave default_version out,
                                                              # but if you do the first version used will become the default
      version 1 do
        cache as: 'v1' do
          resources :authorizations
        end
      end

      version 2 do
        inherit from: 'v1'
      end
    end

rake routes outputs:

    api_authorizations      GET    /api/authorizations(.:format)          api/v1/authorizations#index
                            POST   /api/authorizations(.:format)          api/v1/authorizations#create
    new_api_authorization   GET    /api/authorizations/new(.:format)      api/v1/authorizations#new
    edit_api_authorization  GET    /api/authorizations/:id/edit(.:format) api/v1/authorizations#edit
     api_authorization      GET    /api/authorizations/:id(.:format)      api/v1/authorizations#show
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

    api vendor_string: "myvendor", default_version: 1 do
      version 1 do
        cache as: 'v1' do
          resources :authorizations, only: :create
          resources :foo
          resources :bar
        end
      end

      version 2 do
        cache as: 'v2' do
          inherit from: 'v1'
          resources :my_new_resource
        end
      end

      # V3 has everything in V2, and everything in V1 as well by virtue of V1 being cached in V2.
      version 3 do
        inherit from: 'v2'
      end
    end

And finally `rake routes` outputs:

    api_authorizations        POST   /api/authorizations(.:format)           api/v1/authorizations#create
                api_foo_index GET    /api/foo(.:format)                      api/v1/foo#index
                              POST   /api/foo(.:format)                      api/v1/foo#create
                  new_api_foo GET    /api/foo/new(.:format)                  api/v1/foo#new
                 edit_api_foo GET    /api/foo/:id/edit(.:format)             api/v1/foo#edit
                      api_foo GET    /api/foo/:id(.:format)                  api/v1/foo#show
                              PUT    /api/foo/:id(.:format)                  api/v1/foo#update
                              DELETE /api/foo/:id(.:format)                  api/v1/foo#destroy
                api_bar_index GET    /api/bar(.:format)                      api/v1/bar#index
                              POST   /api/bar(.:format)                      api/v1/bar#create
                  new_api_bar GET    /api/bar/new(.:format)                  api/v1/bar#new
                 edit_api_bar GET    /api/bar/:id/edit(.:format)             api/v1/bar#edit
                      api_bar GET    /api/bar/:id(.:format)                  api/v1/bar#show
                              PUT    /api/bar/:id(.:format)                  api/v1/bar#update
                              DELETE /api/bar/:id(.:format)                  api/v1/bar#destroy
                              POST   /api/authorizations(.:format)           api/v2/authorizations#create
                              GET    /api/foo(.:format)                      api/v2/foo#index
                              POST   /api/foo(.:format)                      api/v2/foo#create
                              GET    /api/foo/new(.:format)                  api/v2/foo#new
                              GET    /api/foo/:id/edit(.:format)             api/v2/foo#edit
                              GET    /api/foo/:id(.:format)                  api/v2/foo#show
                              PUT    /api/foo/:id(.:format)                  api/v2/foo#update
                              DELETE /api/foo/:id(.:format)                  api/v2/foo#destroy
                              GET    /api/bar(.:format)                      api/v2/bar#index
                              POST   /api/bar(.:format)                      api/v2/bar#create
                              GET    /api/bar/new(.:format)                  api/v2/bar#new
                              GET    /api/bar/:id/edit(.:format)             api/v2/bar#edit
                              GET    /api/bar/:id(.:format)                  api/v2/bar#show
                              PUT    /api/bar/:id(.:format)                  api/v2/bar#update
                              DELETE /api/bar/:id(.:format)                  api/v2/bar#destroy
    api_my_new_resource_index GET    /api/my_new_resource(.:format)          api/v2/my_new_resource#index
                              POST   /api/my_new_resource(.:format)          api/v2/my_new_resource#create
      new_api_my_new_resource GET    /api/my_new_resource/new(.:format)      api/v2/my_new_resource#new
     edit_api_my_new_resource GET    /api/my_new_resource/:id/edit(.:format) api/v2/my_new_resource#edit
          api_my_new_resource GET    /api/my_new_resource/:id(.:format)      api/v2/my_new_resource#show
                              PUT    /api/my_new_resource/:id(.:format)      api/v2/my_new_resource#update
                              DELETE /api/my_new_resource/:id(.:format)      api/v2/my_new_resource#destroy
                              POST   /api/authorizations(.:format)           api/v3/authorizations#create
                              GET    /api/foo(.:format)                      api/v3/foo#index
                              POST   /api/foo(.:format)                      api/v3/foo#create
                              GET    /api/foo/new(.:format)                  api/v3/foo#new
                              GET    /api/foo/:id/edit(.:format)             api/v3/foo#edit
                              GET    /api/foo/:id(.:format)                  api/v3/foo#show
                              PUT    /api/foo/:id(.:format)                  api/v3/foo#update
                              DELETE /api/foo/:id(.:format)                  api/v3/foo#destroy
                              GET    /api/bar(.:format)                      api/v3/bar#index
                              POST   /api/bar(.:format)                      api/v3/bar#create
                              GET    /api/bar/new(.:format)                  api/v3/bar#new
                              GET    /api/bar/:id/edit(.:format)             api/v3/bar#edit
                              GET    /api/bar/:id(.:format)                  api/v3/bar#show
                              PUT    /api/bar/:id(.:format)                  api/v3/bar#update
                              DELETE /api/bar/:id(.:format)                  api/v3/bar#destroy
                              GET    /api/my_new_resource(.:format)          api/v3/my_new_resource#index
                              POST   /api/my_new_resource(.:format)          api/v3/my_new_resource#create
                              GET    /api/my_new_resource/new(.:format)      api/v3/my_new_resource#new
                              GET    /api/my_new_resource/:id/edit(.:format) api/v3/my_new_resource#edit
                              GET    /api/my_new_resource/:id(.:format)      api/v3/my_new_resource#show
                              PUT    /api/my_new_resource/:id(.:format)      api/v3/my_new_resource#update
                              DELETE /api/my_new_resource/:id(.:format)      api/v3/my_new_resource#destroy

License
=======
Copyright (c) 2012 Erich Menge

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
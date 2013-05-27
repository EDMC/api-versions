# api-versions

[![Build Status](https://travis-ci.org/erichmenge/api-versions.png?branch=master)](https://travis-ci.org/erichmenge/api-versions)
[![Gem Version](https://badge.fury.io/rb/api-versions.png)](http://badge.fury.io/rb/api-versions)
[![Coverage Status](https://coveralls.io/repos/erichmenge/api-versions/badge.png)](https://coveralls.io/r/erichmenge/api-versions)
[![Code Climate](https://codeclimate.com/github/erichmenge/api-versions.png)](https://codeclimate.com/github/erichmenge/api-versions)

### Requirements
* Rails 4 or Rails 3
* Ruby 1.9 or greater


#### api-versions is a Gem to help you manage your Rails API endpoints.
api-versions is very lightweight. It adds a generator and only one method to the Rails route mapper.

##### It helps you in three ways:

* Provides a DSL for versioning your API in your routes file, favoring client headers vs changing the resource URLs.
* Provides methods to cache and retrieve resources in your routes file to keep it from getting cluttered
* Provides a generator to bump your API controllers to the next version, while inheriting the previous version.

*See below for more details on each of these topics*

#### Assumptions api-versions makes:
* You want the client to use headers to specify the API version instead of changing the URL. (`Accept` header of `application/vnd.myvendor+json;version=1` for example)
* You specify your API version in whole integers. v1, v2, v3, etc.
  If you need semantic versioning for an API you're likely making too many backwards incompatible changes. API versions should not change all that often.
* Your API controllers will live under the `api/v{n}/` directory. For example `app/controllers/api/v1/authorizations_controller.rb`.

## Installation
In your Gemfile:

    gem "api-versions", "~> 1.0"

## Versions are specified by header, not by URL
A lot of APIs are versioned by changing the URL. `http://test.host/api/v1/some_resource/new` for example.
But is some_resource different from version 1 to version 2? It is likely the same resource, it is simply the interface that is changing.
api-versions prefers the URLs stay the same. `http://test.host/api/some_resource/new` need not ever change (so long as the resource exists). The client specifies how it wants to interface with
this resource with the `Accept` header. So if the client wants version 2 of the API, the `Accept` header might look like this: `application/vnd.myvendor+json;version=2`. A complete example is
below.

## DSL ##
api-versions provides a (very) lightweight DSL for your routes file. Everything having to do with your routes API lives in the api block. This DSL helps you version your API as well as providing a caching mechanism to prevent the need of copy/pasting the same resources into new versions of the API.

For example:

In your routes.rb file:

``` ruby
  # You can leave default_version out, but if you do the first version used will become the default
  api vendor_string: "myvendor", default_version: 1 do
    version 1 do
      cache as: 'v1' do
        resources :authorizations
      end
    end

    version 2 do
      inherit from: 'v1'
    end
  end
```

`rake routes` outputs:

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


Then the client simply sets the Accept header `application/vnd.myvendor+json;version=1`. If no version is specified, the default version you set will be assumed.
You'll of course still need to copy all of your controllers over (or bump them automatically, see below), even if they haven't changed from version to version.  At least you'll remove a bit of the mess in your routes file.

A more complicated example:

``` ruby
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
```

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
## api_versions:bump
The api-versions gem provides a Rails generator called `api_versions:bump`. This generator will go through all of your API controllers and find the highest version number and bump
all controllers with it up to the next in sequence.

If for example you have a controller `api/v1/authorizations_controller.rb` it will create `api/v2/authorizations_controller.rb` and inside:

``` ruby
class Api::V2::AuthorizationsController < Api::V1::AuthorizationsController
end
```

So instead of copying your prior version controllers over to the new ones and duplicating all the code in them, you can redefine specific methods,
or start from scratch by removing the inheritance.

## Passing Rails Routing options
The api-versions routing DSL will pass any options that are regularly accepted by Rails' own routing DSL. For example, if you are using an api subdomain and don't need your paths prefixed with `/api`, you can override it as you normally would:

```ruby
api vendor_string: 'myvendor', default_version: 1, path: '' do
  version 1 do
    cache as: 'v1' do
      resources :foo
    end
  end
end
```

Then a `rake routes` would show your desires fulfilled:

```
                              GET    /foo(.:format)                      api/v1/foo#index
                              POST   /foo(.:format)                      api/v1/foo#create
                              GET    /foo/new(.:format)                  api/v1/foo#new
                              GET    /foo/:id/edit(.:format)             api/v1/foo#edit
                              GET    /foo/:id(.:format)                  api/v1/foo#show
                              PUT    /foo/:id(.:format)                  api/v2/foo#update
                              DELETE /foo/:id(.:format)                  api/v2/foo#destroy
```

## Testing
Because controller tests will not go through the routing constraints, you will get routing errors when testing API
controllers.

To avoid this problem you can use request/integration tests which will hit the routing constraints.

RSpec:

```ruby
# spec/requests/api/v1/widgets_controller_spec.rb
require 'spec_helper'

describe Api::V1::WidgetsController do
  describe "GET 'index'" do
    it "should be successful" do
      get '/api/widgets', {}, 'HTTP_ACCEPT' => 'application/vnd.myvendor+json; version=1'
      response.should be_success
    end
  end
end
```

Test::Unit:

```ruby
# test/integration/api/v1/widgets_controller_test.rb
require 'test_helper'

class Api::V1::WidgetsControllerTest < ActionDispatch::IntegrationTest
  test "GET 'index'" do
    get '/api/widgets', {}, 'HTTP_ACCEPT' => 'application/vnd.myvendor+json; version=1'
    assert_response 200
  end
end
```

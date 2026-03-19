# TinyRestClient

A minimal HTTP client wrapper for Rails, built on top of Typhoeus. Perfect for quickly building clean, opinionated API clients with almost no boilerplate.

### Features

- Simple class-level DSL for configuration
- Built-in support for Bearer, API Key and Basic Auth
- Chainable-like request methods (GET, POST, PATCH, PUT, DELETE, HEAD, OPTIONS)

## Why TinyRestClient?

- Small, focused API clients
- Internal services and microservices
- Rails apps that want minimal abstraction
- Developers who prefer convention over configuration

## Table of Contents

- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Rails Generator](#rails-generator)
- [Configuration](#configuration)
- [Authorization](#authorization)
- [Retries & Delay (Throttling)](#retries--delay-throttling)
- [Making Requests](#making-requests)
- [Response Handling](#response-handling)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add this line to your Gemfile:

```bash
gem "tiny-rest-client"
```

Or install it manually:

```bash
gem install tiny-rest-client
```

## Basic Usage

```ruby
class MyClient < TinyRestClient::Core
  # define base API path (required)
  api_path "https://api.example.com/v1"

  # set an authorization strategy (optional)
  authorization :bearer, token: "your_token"

  # pass single header (optional)
  header "Accept", "application/json"

  # pass bunch of headers (optional)
  headers "User-Agent": "MyTest/1.0", "Accept": "application/json"

  # define actions (optional)
  def fetch_todos(**)
    get("/todos", **)
  end

  def fetch_todo(id)
    get("/todos/#{id}")
  end

  def create_todo(**)
    post("/todos", **)
  end

  def update_todo(id, **)
    patch("/todos/#{id}", **)
  end

  def destroy_todo(id)
    delete("/todos/#{id}")
  end
end

client = MyClient.new

client.fetch_todos(page: 1, per_page: 20)
client.fetch_todo(1)
client.create_todo(name: "Custom")
client.update_todo(1, { status: "finished" })
client.destroy_todo(1)
```

## Rails Generator

The gem includes a built-in Rails generator to quickly scaffold new API clients.

```bash
rails generate tiny_rest_client:client NAME [URL] [options]
```

### Available options

| Option          | Default       | Description                                                 |
|-----------------|---------------|-------------------------------------------------------------|
| NAME            | (required)    | Client name (supports nesting like `api/v1/stripe`)         |
| URL             | (none)        | Base API URL | `rails g ... stripe https://api.stripe.com`  |
| --namespace     | `clients`     | Root folder under `app/` (e.g. `app/services/`)             |

### Basic usage

```bash
# Basic client
rails generate tiny_rest_client:client stripe

# Custom base URL
rails generate tiny_rest_client:client stripe https://api.stripe.com/v1

# Nested namespace (creates app/clients/api/v1/payment_client.rb)
rails generate tiny_rest_client:client api/v1/payment https://api.example.com/v1

# Custom namespace (creates app/custom/stripe_client.rb)
rails generate tiny_rest_client:client stripe https://api.example.com/v1 --namespace=custom
```

## Configuration

You can configure client setup at the class level:

```ruby
class MyClient < TinyRestClient::Core
  api_path "https://api.example.com/v1"
  authorization :bearer, token: "your_token"
  headers "Accept": "application/json", "User-Agent": "MyApp/1.0"
end

client = MyClient.new
```

Or per instance:

```ruby
class MyClient < TinyRestClient::Core; end

client = MyClient.new(
  api_path: "https://api.example.com/v1",
  auth: { bearer: { token: "your_token" } },
  headers: { "User-Agent": "MyApp/1.0" }
)
```

## Authorization

The library ships with a small set of built‑in strategies:

* Bearer Token
* API Keys
* Basic Auth

You can configure authentication either at the class level using the
`authorization` helper or at runtime via the `auth` key when initializing a
client (see "Configuration" above).

#### Options Overview

```ruby
# Bearer
:bearer, token: String                             # Authorization: Bearer <token>

# API key
:api_key, token: String                            # X-API-Key: <token>
:api_key, token: String, name: String              # <Custom>: <token>
:api_key, token: String, in: :param                # ?api_key=<token>
:api_key, token: String, in: :param, name: String  # ?<custom>=<token>

# Basic
:basic_auth, user: String, password: String        # Authorization: Basic <base64(user:password)>
```

### Bearer Token

```ruby
class MyClient < TinyRestClient::Core
  authorization :bearer, token: "your_token"
end

# per-instance
MyClient.new(auth: { bearer: { token: "your_token" } })
```

### API Key

```ruby
class MyClient < TinyRestClient::Core
  authorization :api_key, token: "your_token"
end

# per-instance
MyClient.new(auth: { api_key: { token: "your_token" } })
```

### Basic Auth

```ruby
class MyClient < TinyRestClient::Core
  authorization :basic_auth, user: "name", password: "secret"
end

# per-instance
MyClient.new(auth: { basic_auth: { user: "name", password: "secret" } })
```

## Retries & Delay (Throttling)

The library supports automatic retries on server errors and a simple fixed delay (throttling) between requests, both configurable at class or instance level.

### Retries

Retries only happen on configurable HTTP status codes (default: 500, 502, 503, 504).

```ruby
class MyClient < TinyRestClient::Core
  # retry 3 times on default 5xx errors
  retries 3

  # custom retryable codes
  retries 5, on: [500..599]
end

# per-instance
client = MyClient.new(retries: { count: 3, on: [500..599] })
```

### Delay (Throttling)

Add a fixed delay (seconds) between each request - useful for rate-limited APIs (default: 1.0 second).

```ruby
class MyClient < TinyRestClient::Core
  retries 3, delay: 1.0   # wait 1 second between every retry
end

# per-instance
client = MyClient.new(retries: { count: 3, delay: 1.0 })
```

## Making Requests

The standard HTTP methods are available directly on every client instance automatically include any headers or authorization configuration you defined.

```ruby
get("/users", page: 1, per_page: 10)            # GET request with query parameters
post("/users", name: "John", surname: "Doe")    # POST request with body
put("/users/1")                                 # PUT request
patch("/users/1")                               # PATCH request
delete("/users/1")                              # DELETE request
head("/users/1")                                # HEAD request
options("/users")                               # OPTIONS request
```

## Response Handling

Every request returns an instance of [TinyRestClient::Response](https://github.com/Dabrovsky/tiny-rest-client/blob/main/lib/tiny_rest_client/response.rb). A thin
wrapper around the raw Typhoeus response that provides a few convenient
helpers:

| Method | Description |
|--------|-------------|
| success? | Helper that represent successful response. |
| failure? | The opposite. |
| timed_out? | Returns request timeout status |
| code | HTTP status code (e.g. `200`, `404`). |
| status | Returns code symbol (e.g. `:ok`, `:couldnt_connect`). |
| headers | Hash of response headers (keys are not normalized). |
| body | Auto-parsed JSON (symbolized keys). If parsing fails, returns the original raw string. |

```ruby
response.success?    # true if code 200–299
response.failure?    # opposite
response.timed_out?  # Typhoeus timed_out status
response.code        # HTTP status code
response.status      # Typhoeus return_code symbol
response.body        # auto-parsed JSON hash or raw string
response.headers     # hash of response headers
```

## Error Behavior

TinyRestClient does not raise exceptions for HTTP status codes.

Network-level errors (timeouts, connection failures, etc.) are reflected in:

* response.success? / response.failure?
* response.timed_out?
* response.status

This makes error handling explicit and predictable.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/Dabrovsky/tiny-rest-client/blob/main/LICENSE).

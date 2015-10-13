# HMACDaddy

A plug to validate and parse HMAC-signed JSON

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add hmac_daddy to your list of dependencies in `mix.exs`:

        def deps do
          [{:hmac_daddy, "~> 0.0.1"}]
        end

## Configuration

  1. Configure HMACDaddy with your shared token (e.g. in `config/config.exs`):

        config :hmac_daddy, secret_token: "12345"

  1. (Optional) Set the name of the header (defaults to "x-hub-signature" out of
     the box, which is what you want for GitHub webhooks):

        config :hmac_daddy, secret_token: "12345",
                            signature_header: "x-hmac-verification"

  1. Add HMACDaddy to your plug parsing pipeline in `lib/APP/endpoint.ex`:

        plug Plug.Parsers,
          parsers: [:urlencoded, :multipart, HMACDaddy, :json],
          pass: ["*/*"],
          json_decoder: Poison

  1. (Recommended) Add the RequireHMAC plug to your controller or pipeline to
     ensure that all incoming requests are signed:

        pipeline :github do
          plug HMACDaddy.RequireHMAC
        end

## Using

With this plug in place, all JSON requests that have a signature header will be
validated.

Invalid signatures will raise an error:

      curl -X POST \
           -H'x-hub-signature: sha1=xxxx' \
           -H'Content-Type: application/json' \
           -d'{"foo":"bar"}' \
           http://localhost:4000/api/hooks
      # ... raises error

Valid signatures will be parsed as JSON as normal:

      curl -X POST \
           -H'x-hub-signature: sha1=892c80a454269266a0536734255f66518cd86f97' \
           -H'Content-Type: application/json' \
           -d'{"foo":"bar"}' \
           http://localhost:4000/api/hooks
      # => {"ok":"true"}

By default, requests *without* signatures will fall through to the standard JSON
parser, so if you want to ensure that requests are signed correctly, you should
add the RequireHMAC plug.

Without RequireHMAC:

      curl -X POST \
           -H'Content-Type: application/json' \
           -d'{"foo":"bar"}' \
           http://localhost:4000/api/hooks
      # => {"ok":"true"}

With RequireHMAC:

      curl -X POST \
           -H'Content-Type: application/json' \
           -d'{"foo":"bar"}' \
           http://localhost:4000/api/hooks
      # ... raises error

# HMACDaddy

A plug to validate and parse HMAC-signed JSON

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add hmac_daddy to your list of dependencies in `mix.exs`:

        def deps do
          [{:hmac_daddy, "~> 0.0.1"}]
        end

  2. Ensure hmac_daddy is started before your application:

        def application do
          [applications: [:hmac_daddy]]
        end

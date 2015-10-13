defmodule HMACDaddyTest do
  use ExUnit.Case
  use Plug.Test
  doctest HMACDaddy

  defmodule JSON do
    def decode!("{id: 1}") do
      %{"id" => 1}
    end
  end

  def json_conn(body, headers \\ default_headers ) do
    Enum.reduce(headers, conn(:post, "/", body), fn ({header, value}, c) ->
      put_req_header(c, header, value)
    end)
  end

  def default_headers, do: %{"content-type" => "application/json"}

  def invalid_signature do
    Map.put_new(default_headers, "x-hub-signature", "nope")
  end

  def valid_signature do
    Map.put_new(default_headers, "x-hub-signature", "sha1=c37206de04da7b5373bf915c3966e0d97e347848")
  end

  def parse(conn, opts \\ []) do
    opts = opts
           |> Keyword.put_new(:parsers, [HMACDaddy, :json])
           |> Keyword.put_new(:json_decoder, JSON)
    Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  end


  test "request without HMAC signature is passed along" do
    conn = json_conn("{id: 1}") |> parse()
    assert conn.params["id"] == 1
  end

  test "request with invalid HMAC signature is halted" do
    exception = assert_raise HMACDaddy.InvalidSignatureError, fn ->
      json_conn("{id: 1}", invalid_signature) |> parse
    end
    assert Plug.Exception.status(exception) == 403
  end

  test "request with valid HMAC signature is verified and parsed" do
    conn = json_conn("{id: 1}", valid_signature) |> parse()
    assert conn.params["id"] == 1
    assert conn.private[:hmac_verified]
  end
end

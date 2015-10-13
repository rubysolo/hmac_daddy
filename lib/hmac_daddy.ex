defmodule HMACDaddy do

  defmodule InvalidSignatureError do
    @moduledoc """
    Error raised when the provided HMAC signature does not match the calculated value
    """

    defexception message: "HMAC signature is not valid", plug_status: 403
  end

  @behaviour Plug.Parsers
  import Plug.Conn

  def parse(conn, "application", subtype, _headers, opts) do
    decoder = Keyword.get(opts, :json_decoder) ||
                raise ArgumentError, "HMACDaddy parser expects a :json_decoder option"

    signature = List.keyfind(conn.req_headers, sig_header, 0)

    if hmac_json_request?(subtype, signature) do
      conn
      |> read_body(opts)
      |> verify_signature(signature)
      |> decode(decoder)
    else
      {:next, conn}
    end
  end

  defp sig_header, do: Application.get_env(:hmac_daddy, :signature_header, "x-hub-signature")

  defp token, do: Application.get_env(:hmac_daddy, :secret_token)

  defp hmac_json_request?(subtype, {_, _signature}), do: json_request?(subtype)
  defp hmac_json_request?(_subtype, _), do: false

  defp json_request?(subtype) do
    subtype == "json" || String.ends_with?(subtype, "+json")
  end

  defp verify_signature({:more, _, conn}, _sig) do
    {:error, :too_large, conn}
  end

  defp verify_signature({:ok, "", conn}, _sig) do
    {:ok, %{}, conn}
  end

  defp verify_signature({:ok, body, conn}, {_, signature}) do
    if request_valid?(signature, body) do
      {:ok, body, put_private(conn, :hmac_verified, true)}
    else
      {:error, "", halt(conn)}
    end
  end

  defp decode({:ok, body, conn}, decoder) do
    case decoder.decode!(body) do
      terms when is_map(terms) ->
        {:ok, terms, conn}
      terms ->
        {:ok, %{"_json" => terms}, conn}
    end
  rescue
    e -> raise Plug.Parsers.ParseError, exception: e
  end

  defp decode(error_conn, _), do: raise InvalidSignatureError

  defp request_valid?(signature, body) do
    computed = "sha1=#{ signature_for(body) }"
    Plug.Crypto.secure_compare(String.downcase(computed), String.downcase(signature))
  end

  # generate SHA1 HMAC signature for given string
  defp signature_for(text) do
    :crypto.hmac(:sha, token, text) |> Base.encode16
  end
end

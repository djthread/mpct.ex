defmodule Mpct.PageController do
  use Mpct.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

defmodule ChatappWeb.PageController do
  use ChatappWeb, :controller
  import ChatappWeb.UserAuth

  plug :require_authenticated_user

  def index(conn, _params) do
    user_token = Phoenix.Token.sign(conn, "user socket", conn.assigns.current_user.id)
    conn = assign(conn, :user_token, user_token)
    render(conn, :index)
  end

  def hello(conn, _params) do
    render(conn, :hello)
  end
end

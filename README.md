# Chatapp Installation Guide

1. Download zip file from D2L or github https://github.com/totorocupcake/ccps706
2. Unzip the downloaded zip file
3. Install erlang and elixir from https://elixir-lang.org/ Note: Erlang and Elixir are separate installs, refer to https://elixir-lang.org/
4. Install PostgreSQL from https://www.postgresql.org/
Use the below Postgress settings (or change /config/dex.exs file setting for your own Postgres settings) :
Username: postgres password:postgres 
5432 port (default)
5. Install git git-scm.com
6. In terminal of the project folder type mix deps.get 
7. Then mix ecto.setup
8. Then mix ecto.migrate
9. Then mix phx.server
10. Then browse local LAN url on port 4000 to access the app through local LAN.
e.g. for me it would be http://192.168.56.1:4000/  (replace the ip address with your own LAN local IP address)

# Chatapp Run Server and Client
1. After installation is done, you just need to type into terminal of the chatapp folder: mix phx.server
2. Then browse local LAN url on port 4000 to access the app through local LAN.
e.g. for me it would be http://192.168.56.1:4000/  (replace the ip address with your own LAN local IP address)
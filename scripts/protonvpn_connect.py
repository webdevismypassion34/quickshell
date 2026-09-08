import asyncio
import sys

from proton.vpn.cli.core.controller import Controller, Params
from proton.vpn.session import ServerList


async def main():
  if len(sys.argv) < 2:
    print('usage: python3 protonvpn_connect.py <city>')
    sys.exit(1)

  city = sys.argv[1]

  controller = await Controller.create(Params(), None)

  if not controller.is_logged_in:
    print('not logged in to protonvpn')
    sys.exit(1)

  server_list = await controller.get_updated_server_list()
  servers = ServerList.get_servers_in_city(server_list.logicals, city)
  servers = ServerList.get_available_servers(servers, controller.user_tier)
  server = ServerList.get_fastest_server(servers)

  if not server:
    print(f'no available server found in {city}')
    sys.exit(1)

  connection_state = await controller.connect(server)

  if connection_state:
    print(f'connected to {server.name} in {city}')
  else:
    print(f'failed to connect to {server.name} in {city}')
    sys.exit(1)


if __name__ == '__main__':
  asyncio.run(main())

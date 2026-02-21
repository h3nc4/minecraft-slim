# minecraft slim

A scratch-built container featuring the Paper Minecraft server.

## Usage

Create a persistent data directory:

```bash
mkdir data
echo "eula=true" >data/eula.txt
chown -R 65534:65534 data
````

Run the container:

```bash
docker run -d \
  -p 25565:25565 \
  -v "${PWD}/data:/data" \
  --name minecraft \
  h3nc4/minecraft-slim
```

## Environment Variables

| Variable  | Default      | Description            |
| --------- | ------------ | ---------------------- |
| JAVA_OPTS | JVM defaults | Additional JVM options |

## Volumes

| Path  | Description           |
| ----- | --------------------- |
| /data | World and server data |

## License

minecraft-slim is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

minecraft-slim is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with minecraft-slim. If not, see <https://www.gnu.org/licenses/>.

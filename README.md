# minecraft slim

The Paper Minecraft server on `FROM scratch`, with a Temurin JRE and nothing else. The image lacks a shell and a package manager, which leaves the server as the only thing it can run.

## Setting up

The server needs a data directory on the host, owned by the uid the container runs as, and it refuses to start until Mojang's EULA is accepted.

```bash
mkdir data
echo "eula=true" >data/eula.txt
doas chown -R 65534:65534 data
```

Writing `eula=true` states agreement to the [Minecraft EULA](https://aka.ms/MinecraftEULA). Read it before doing that, since nothing here asks again.

The `chown` needs root, because 65534 is `nobody` and the directory belongs to whoever created it. Without it the server cannot write its world and exits.

## Running

```bash
docker run -d \
  -p 25565:25565 \
  -v "${PWD}/data:/data" \
  --name minecraft \
  h3nc4/minecraft-slim
```

The server console is on the container's stdin. Start it with `-it` in place of `-d` to type commands, or attach later with `docker attach minecraft`. The entrypoint passes `nogui`, so no window is involved either way.

## Passing JVM options

**Use `JDK_JAVA_OPTIONS`.** The entrypoint execs `java` directly, and `java` reads that variable.

```bash
docker run -d \
  -p 25565:25565 \
  -v "${PWD}/data:/data" \
  -e JDK_JAVA_OPTIONS="-Xmx4G -Xms4G" \
  --name minecraft \
  h3nc4/minecraft-slim
```

Every variable that arrives prints a `Picked up` line at startup, which confirms it was read.

**The image sizes the heap at 75% of the container's memory limit.** It sets `JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0"`, so a container started with `--memory 4g` gets a 3G heap without any flag. `JDK_JAVA_OPTIONS` is read after that default, so an `-Xmx` or another `-XX:MaxRAMPercentage` there overrides it. Passing `JAVA_TOOL_OPTIONS` at run time replaces the default outright, and the JVM falls back to its own 25% unless the new value sizes the heap.

`JAVA_OPTS` is dropped. The entrypoint is an exec form that expands no variable, and `java` ignores that name.

## Reference

| Detail | Value |
| --- | --- |
| Port | 25565 |
| Data | `/data`, the working directory |
| User | `65534:65534` |
| Server | Paper, `/opt/paper/paper.jar` |
| Runtime | Temurin JRE 25 |

`/data` holds the world, `server.properties`, `eula.txt`, plugins and logs. It is the only path the server writes to, which makes it the only path a backup has to cover.

## License

<!-- vale off -->

minecraft-slim is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

minecraft-slim is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with minecraft-slim. If not, see <https://www.gnu.org/licenses/>.

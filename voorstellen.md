# Voorstellen voor vulnerabilities

Plaats in dit document een overzicht van de vulnerabilities die je wil onderzoeken. We zullen dan samen kiezen welke we effectief gaan uitwerken.

<span style="color:green">

## CVE-2021-42013 (Apache HTTP server path traversal)

</span>


It was found that the fix for CVE-2021-41773 in Apache HTTP Server 2.4.50 was insufficient. An attacker could use a path traversal attack to map URLs to files outside the directories configured by Alias-like directives. If files outside of these directories are not protected by the usual default configuration "require all denied", these requests can succeed. If CGI scripts are also enabled for these aliased pathes, this could allow for remote code execution. This issue only affects Apache 2.4.49 and Apache 2.4.50 and not earlier versions.

Link: <https://www.cve.org/CVERecord?id=CVE-2021-42013>

## CVE-2020-15778 (OpenSSH command injection)

scp in OpenSSH through 8.3p1 allows command injection in the scp.c toremote function, as demonstrated by backtick characters in the destination argument. NOTE: the vendor reportedly has stated that they intentionally omit validation of "anomalous argument transfers" because that could "stand a great chance of breaking existing workflows."

Link: <https://www.cve.org/CVERecord?id=CVE-2020-15778>

## CVE-2019-18634 (Sudo password bypass)

In Sudo before 1.8.26, if pwfeedback is enabled in /etc/sudoers, users can trigger a stack-based buffer overflow in the privileged sudo process. (pwfeedback is a default setting in Linux Mint and elementary OS; however, it is NOT the default for upstream and many other packages, and would exist only if enabled by an administrator.) The attacker needs to deliver a long string to the stdin of getln() in tgetpass.c.

Link: <https://www.cve.org/CVERecord?id=CVE-2019-18634>

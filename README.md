![GitHub last commit](https://img.shields.io/github/last-commit/yakisyst3m/CyberGhost_VPN_for_Debian) ![GitHub release-date](https://img.shields.io/github/release-date/yakisyst3m/CyberGhost_VPN_for_Debian)

# [ CyberGhost_VPN_for_Debian ]

# 1 Présentation :  
La société CyberGhost n'a pas créé de script de lancement pour Debian, c'est la raison pour laquelle je vous propose ce script.  
Il vous permettra de switcher facilement entre les différents pays que vous aurez mis dans /etc/openvpn/.  
Il vous fera un état des fuites DNS.

# 2 Téléchargement de la configuration openvpn :
- Téléchargez vos fichier de configuration  
- Récupérer votre login et mot de passe unique pour chaque configuration (1 pays = 1 configuration)

# 3 Configuration des fichiers :  
- **Déplacer les fichiers dans :** /etc/openvpn/
- **Renommer le fichier de config + créer un fichier d'authentification**
```
mv openvpn.ovpn CG_Yourcountry.conf ; touch userCountry.txt
```
```
exemple : mv openvpn.ovpn CG_Spain.conf ; touch userSpain.txt
```

- **Dans le fichier : userCountry.txt**  
*Insérer le login et en dessous le mot de passe*

- **Dans le fichier : CG_Yourcountry.conf**   
*Modifier cette ligne en début de fichier*   
`auth-user-pass /etc/openvpn/userCountry.txt`  
*Ajouter ces lignes à la fin du fichier*  
`up /etc/openvpn/update-resolv-conf`  
`down /etc/openvpn/update-resolv-conf`  

- **Rendre exécutable le script :**
```
chmod +x OpenVpn_Start_Stop-V5.sh
```
- **Pour lancer :**
```
./OpenVpn_Start_Stop-V5.sh
```

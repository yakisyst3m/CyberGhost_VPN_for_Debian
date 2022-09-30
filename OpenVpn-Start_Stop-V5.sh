#!/bin/bash

# Cyberghost application for Debian by Yakisyst3m //

# move all files to : /etc/openvpn/
#       mv openvpn.ovpn CG_Yourcountry.conf ; touch userCountry.txt
# exemple : mv openvpn.ovpn CG_Spain.conf ; touch userSpain.txt

# put your login and below password in file userCountry.txt

# modify or add at begin of file CG_Yourcountry.conf :
#       auth-user-pass /etc/openvpn/userCountry.txt

# add at end of file CG_Yourcountry.conf :
#       up /etc/openvpn/update-resolv-conf
#       down /etc/openvpn/update-resolv-conf
# 

# For Run :
# ./OpenVpn_Start_Stop-V5.sh

# V5

# Déclaration des couleurs
rouge='\e[1;31m'
vert='\e[1;32m'
jaune='\e[1;33m'
bleu='\e[1;34m' 
violet='\e[1;35m'
neutre='\e[0;m'
bleufondjaune='\e[7;44m\e[1;33m'
souligne="\e[4m"
neutrePolice='\e[0m'

RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# Variables
api_domain='bash.ws'
error_code=1
IPPUBLIQUE=$(wget -qO- icanhazip.com)

# Clear de l'écran à chaque lancement du programme
clear

# Fonnctions donnant l'IP Publique
function ipPubliqueVPN() {
    echo -e "\t\n${bleu}[ ----------------------------------------------    IP PUBLIQUE - VPN démarré ]${neutre}"
    IPPUBLIQUE=$(wget -qO- icanhazip.com) && echo -e "${souligne}\nMa nouvelle IP Publique AVEC VPN${neutre} : ${vert}$IPPUBLIQUE${neutre}\n"
}

function ipPublique() {
    echo -e "\t\n${bleu}[ ----------------------------------------------    IP PUBLIQUE - sans VPN ]${neutre}"
    IPPUBLIQUE=$(wget -qO- icanhazip.com) && echo -e "${souligne}\nMa nouvelle IP Publique sans VPN${neutre} : ${rouge}$IPPUBLIQUE${neutre}\n"
}

# Fonction de compte à rebours
decompte() {
    i=$1
    echo " "
    while [[ $i -ge 0 ]] ; do
            echo -e "${rouge}\r "$i secondes" \c ${neutre}"
            sleep 1
            i=$(("$i"-1))
    done
    echo -e "\n${vert} Poursuite du programme ... ${neutre}"
}

# Fonction pour tester les Fuites DNS avec DNS Leaks
function dnsLeaks() {
    echo -e "\t\n${bleu}[ ----------------------------------------------    Test de fuites DNS avec DNS Leaks ]${neutre}"
    function increment_error_code {
        error_code=$((error_code + 1))
    }

    function echo_error {
        (>&2 echo -e "${RED}${1}${NC}")
    }

    function program_exit {
        command -v $1 > /dev/null
        if [ $? -ne 0 ]; then
            echo_error "SVP, installer \"$1\""
            exit $error_code
        fi
        increment_error_code
    }

    function check_internet_connection {
        curl --silent --head  --request GET "https://${api_domain}" | grep "200 OK" > /dev/null
        if [ $? -ne 0 ]; then
            echo_error "Aucune connexion Internet."
            exit $error_code
        fi
        increment_error_code
    }

    program_exit curl
    program_exit ping
    check_internet_connection

    if command -v jq &> /dev/null; then
        jq_exists=1
    else
        jq_exists=0
    fi

    if hash shuf 2>/dev/null; then
        id=$(shuf -i 1000000-9999999 -n 1)
    else
        id=$(jot -w %i -r 1 1000000 9999999)
    fi

    for i in $(seq 1 10); do
        ping -c 1 "${i}.${id}.${api_domain}" > /dev/null 2>&1
    done

    function print_servers {

        if (( $jq_exists )); then

            echo -e ${result_json} | \
                jq  --monochrome-output \
                --raw-output \
                ".[] | select(.type == \"${1}\") | \"\(.ip)\(if .country_name != \"\" and  .country_name != false then \" \t[\(.country_name)\(if .asn != \"\" and .asn != false then \" \(.asn)\" else \"\" end)]\" else \"\" end)\""

        else

            while IFS= read -r line; do
                if [[ "$line" != *${1} ]]; then
                    continue
                fi

                ip=$(echo $line | cut -d'|' -f 1)
                code=$(echo $line | cut -d'|' -f 2)
                country=$(echo $line | cut -d'|' -f 3)
                asn=$(echo $line | cut -d'|' -f 4)

                if [ -z "${ip// }" ]; then
                     continue
                fi

                if [ -z "${country// }" ]; then
                     echo "$ip"
                else
                     if [ -z "${asn// }" ]; then
                         echo "$ip [$country]"
                     else
                         echo "$ip [$country, $asn]"
                     fi
                fi
            done <<< "$result_txt"

        fi
    }

    if (( $jq_exists )); then
        result_json=$(curl --silent "https://${api_domain}/dnsleak/test/${id}?json")
    else
        result_txt=$(curl --silent "https://${api_domain}/dnsleak/test/${id}?txt")
    fi

    dns_count=$(print_servers "dns" | wc -l)

    echo -e "\n${souligne}Ma Nouvelle IP:${neutre}"
    print_servers "ip"

    echo ""
    if [ ${dns_count} -eq "0" ];then
        echo -e "${rouge}TAucun serveur DNS trouvé${neutre}"
    else
        if [ ${dns_count} -eq "1" ];then
            echo -e "${souligne}Tu utilises ${dns_count} serveurs DNS :${neutre}"
        else
            echo -e "${souligne}Tu utilises ${dns_count} serveurs DNS :${neutre}"
        fi
        print_servers "dns"
    fi

    echo ""
    echo -e "${souligne}Rapport :${neutre}"
    print_servers "conclusion"
#exit 0
}

# Fonction de démarrage VPN
function listeVPN() {
    echo -e "\n\n\t[ ${vert}Liste des Pays${neutre} ] - Sélectionner un VPN :"
    y=1
    for i in $(find /etc/openvpn/ -name "CG_*.conf" -exec basename {} .conf \;)
    do
        tab[y]=$i
        echo -e "\t[ $((y++)) ] $i"
    done
    
    echo -e "\n\tChoisir un pays : \c"
    read num
    PAYS=${tab[num]} && echo -e "\n\t[ Pays choisi : ${jaune}$PAYS${neutre} ]"

    echo -e "\t\n${bleu}[ ----------------------------------------------    Démarrage de OpenVPN ]${neutre}"
    echo -e "\n[ ${jaune}Test${neutre} ] - Mon IP Publique avant : $IPPUBLIQUE\n"

    decompte 5 # empêche l'utilisateur de changer de lieu trop rapidement ; cela laisse le temps à openvpn de monter ses tunnels
    ls /run/openvpn/*.pid > /dev/null 2>&1
    if [ "$?" -eq "0" ] ; then
        PAYSenCOURS=$(ps -ef | grep "CG_" | tr -s " " " " | cut -d " " -f 10 | cut -d "-" -f2)
        systemctl stop openvpn@"$PAYSenCOURS".service && echo -e "\n[ ${vert}Arrêt du service openvpn@$PAYSenCOURS.service effectué${neutre} ]\n"
        systemctl start openvpn@"$PAYS".service && echo -e "\n[ ${vert}Démarrage du service openvpn@$PAYS.service effectué${neutre} ]\n"
    else
        systemctl start openvpn@"$PAYS".service && echo -e "\n[ ${vert}Démarrage du service openvpn@$PAYS.service effectué${neutre} ]\n"
    fi
}

# Fonction d'arrêt VPN
function stopOpenVpn() {
    echo -e "\t\n${bleu}[ ----------------------------------------------    Arrêt de OpenVPN ]${neutre}"
    echo -e "\n[ ${jaune}Test${neutre} ] - Mon IP Publique avant : $IPPUBLIQUE\n"
    PAYSenCOURS=$(ps -ef | grep "CG_" | tr -s " " " " | cut -d " " -f 10 | cut -d "-" -f2)
    systemctl stop openvpn@"$PAYSenCOURS".service
    echo -e "\n[ ${jaune}OpenVPN est arrêté${neutre} ]\n"
}

# Menu principale
echo -e "${bleu}[ ======================================================    ${souligne}Voulez vous Démarrer ou arrêter OpenVPN${neutre}${bleu} : ]${neutre}"
echo -e "\t[ ${vert}D${neutre} ] - Pour Démarrer"
echo -e "\t[ ${rouge}A${neutre} ] - Pour Arrêter"
echo -e "\n\t${souligne}Votre choix [ D ou A ]${neutre} : \c"
read choix
if [ "$choix" = "D" ] ; then
    systemctl stop openvpn && echo -e "\n[ ${vert}Arrêt du service openvpn déjà en cours${neutre} ]\n"
    #systemctl start openvpn
    listeVPN
    decompte 10
    dnsLeaks
    ipPubliqueVPN
fi    
if [ "$choix" = "A" ] ; then
    stopOpenVpn
    systemctl stop openvpn
    dnsLeaks
    ipPublique
fi


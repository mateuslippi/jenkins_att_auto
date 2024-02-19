#!/usr/bin/env bash
DIR_DOWNLOAD="/download/jenkins-versions"
DIR_JENKINS="/usr/share/java"
DIR_ATUAL=$(pwd)
VERSOES="versoes.txt"

#root?
if [ $UID -ne 0 ]; then
  echo "Execute o script como root"
  exit 1
fi

#checar diretório atual
if [ "$DIR_ATUAL" != "$DIR_DOWNLOAD" ]; then
  echo "O script deve ser executado de dentro do diretório: $DIR_DOWNLOAD"
  exit 1
fi

#checar existencia do arquivo
if [ ! -f "$VERSOES" ]; then
  echo "Arquivo de versões não encontrado: $VERSOES"
  exit 1
fi

while IFS= read -r p; do
  mkdir -p "DIR_DOWNLOAD/$p"
  cd $DIR_DOWNLOAD/$p" || exit
  wget "https://updates.jenkins.io/download/war/$p/jenkins.war"
  systemctl stop jenkins
  rm -f "$DIR_JENKINS/jenkins.war"
  cp -rfp "jenkins.war" "$DIR_JENKINS/"
  systemctl start jenkins
  until systemctl is-active --quiet jenkins; do
    sleep 1
  done
done < "$VERSOES"

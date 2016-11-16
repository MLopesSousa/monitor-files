#!/bin/bash

if [[ ! $1  || ! $2 ]]; then exit 1; fi

readonly TIMESTAMP="date +%Y-%m-%dT%H:%M:%S-0300"
readonly AMBIENTE=$3

arquivo=$1
repositorio=$2
repositorioDiretorio=$(echo ${repositorio} |awk -F'/' '{print $NF}' |awk -F'.git' '{print $1}')

function commit() {
        mkdir /tmp/$$
        cd /tmp/$$
        git clone ${repositorio} > /dev/null
        cd ${repositorioDiretorio}
        cp -r ${arquivo} ./
        git add . > /dev/null
        git commit -m "$(eval $TIMESTAMP)" > /dev/null
        git push origin master > /dev/null
        rm -rf /tmp/$$
}

while true; do
        retorno=$(inotifywait -r ${arquivo})
        evento=$(echo $retorno |awk '{print $2}')
        arquivo=$(echo $retorno |awk '{print $1}')

        if [[ $evento == "MOVE_SELF" || $evento == "MODIFY" || $evento == "CLOSE_WRITE" ]]; then
                echo "$(eval $TIMESTAMP) FILE ${AMBIENTE} $arquivo $evento ${date}-${time}"
                commit
        fi
done


#!/bin/bash

# pocentaje de aviso 
Porcentaje_Aviso=80
Porcentaje_Critico=85
Porcentaje_sistemas_Archivos=0
#Sistemas de archivos a mirar
Sistemas_Archivos="/dev/xvda1"

HOSTNAME=$(hostname)" (Servidor de Produccion)"
FECHA_HORA=$(date +%d-%m-%Y' '%H:%M:%S)
EMAILS="cjerez@apploaded.com fmedina@apploaded.com alvin@apploaded.com epalacios@apploaded.com mmartinez@apploaded.com"


echo "Analizando el sistema de archivo $Sistemas_Archivos"
Porcentaje_sistemas_Archivos=$(df -h | grep $Sistemas_Archivos | awk '{ print $5 }')
# Nos devuelve un número con tanto por ciento, por ejemplo 21%, Debemos quitar % para comparar números
echo "El uso actual del sistema de archivo $Sistemas_Archivos es del $Porcentaje_sistemas_Archivos"

if [ ${Porcentaje_sistemas_Archivos%"%"} -gt $Porcentaje_Critico ]; then
        echo "Se esta llenado el sistema de archivo es $Sistemas_Archivos"
        # enviamos aviso por correo electrónico
        # enviamos using mail
        echo "$FECHA_HORA: El sistema de archivos en $HOSTNAME ha sobrepasado el $Porcentaje_Critico% de uso con un $Porcentaje_sistemas_Archivos, Intenta reducir el espacio en $HOSTNAME para no colapsar el sistema" | mail -s "Alerta de espacio en disco del servidor $HOSTNAME" $EMAILS
else
        if [ ${Porcentaje_sistemas_Archivos%"%"} -gt $Porcentaje_Aviso ]; then
                echo "Se esta llenado el sistema de archivo es $Sistemas_Archivos"
                # enviamos aviso por correo electrónico
                # enviamos using mail
                echo "$FECHA_HORA: El sistema de archivos en $HOSTNAME ha sobrepasado el $Porcentaje_Aviso% de uso con un $Porcentaje_sistemas_Archivos" | mail -s "Alerta de espacio en disco del servidor $HOSTNAME" $EMAILS
        fi
fi

# Alerta Load Average
Load=$(uptime | awk '{print $10}')
LA=$(echo $Load | tr ',' ' ')
MAX=4.50

Comp=$(echo "$LA > $MAX" | bc)

if [ $Comp -eq '1' ]
then
	TOP_SERVER=$(top -b -n1)
        echo -e "$FECHA_HORA: El Servidor $HOSTNAME ha sobrepasado el $MAX de Load Average con $LA, favor revisar la carga del servidor \nTop Server\n$TOP_SERVER" | mail -s "Alerta de Load Average en el servidor $HOSTNAME" $EMAILS
fi


# Alerta de los Servicios

# Postgres SQL

SERVICE_P='postgresql'
if ps ax | grep -v grep | grep $SERVICE_P > /dev/null
then
        echo "El servicio $SERVICE_P esta ejecutandose"
else
        echo "El servicio $SERVICE_P esta detenido"
        echo "$FECHA_HORA: El servicio $SERVICE_P esta detenido." | mail -s "Alerta de servicio del servidor $HOSTNAME" $EMAILS
	cd /home/ubuntu/
        tail -100 /var/log/postgresql/postgresql-9.3-main.log > log_postgresql.txt
        STARTING_P=$(sudo service postgresql start)
        echo "Inicio:  $STARTING_P" | mail -s "Inicio Auto de Postgresql $HOSTNAME" -A log_postgresql.txt $EMAILS
fi

# https

SERVICE_HTTPS='https'
if ps ax | grep -v grep | grep $SERVICE_HTTPS > /dev/null
then
        echo "El servicio $SERVICE_HTTPS esta ejecutandose"
else
        echo "El servicio $SERVICE_HTTPS esta detenido"
        echo "$FECHA_HORA: El servicio $SERVICE_HTTPS esta detenido." | mail -s "Alerta de servicio del servidor $HOSTNAME" $EMAILS
fi

# Glassfish Server 

SERVICE_G='glassfish'
if ps ax | grep -v grep | grep $SERVICE_G > /dev/null
then
        echo "El servicio $SERVICE_G esta ejecutandose"
else
        echo "El servicio $SERVICE_G esta detenido"
        echo "$FECHA_HORA: El servicio $SERVICE_G esta detenido." | mail -s "Alerta de servicio del servidor $HOSTNAME" $EMAILS
	cd /home/ubuntu/
        tail -100 /opt/glassfish4/glassfish/domains/domain1/logs/server.log > log_glassfish.txt
        cd /opt/glassfish4/bin/
        STARTING_G=$(sudo ./asadmin start-domain)
        cd /home/ubuntu/
        echo "Inicio:  $STARTING_G" | mail -s "Inicio Auto de glassfish $HOSTNAME" -A log_glassfish.txt $EMAILS
fi

# Java

SERVICE_J='java'
if ps ax | grep -v grep | grep $SERVICE_J > /dev/null
then
        echo "El servicio $SERVICE_J esta ejecutandose"
else
        echo "El servicio $SERVICE_J esta detenido"
        echo "$FECHA_HORA: El servicio $SERVICE_J esta detenido." | mail -s "Alerta de servicio del servidor $HOSTNAME" $EMAILS
fi

SERVICE_PGPOOL='pgpool'
if ps ax | grep -v grep | grep $SERVICE_PGPOOL > /dev/null
then
        echo "El servicio $SERVICE_PGPOOL esta ejecutandose"
else
        echo "El servicio $SERVICE_PGPOOL esta detenido"
#        STARTING_PGPOOL=$(sudo service pgpool2 start)
#        echo "Inicio: $STARTING_PGPOOL"
#        echo "$FECHA_HORA: El servicio $SERVICE_PGPOOL esta detenido." | mail -s "Alerta de servicio del servidor $HOSTNAME" $EMAILS
fi

# SSL 

#SERVICE_SSL='ssl'
#if ps ax | grep -v grep | grep $SERVICE_SSL > /dev/null
#then
#        echo "El servicio $SERVICE_SSL esta ejecutandose"
#else
#        echo "El servicio $SERVICE_SSL esta detenido"
#        echo "$FECHA_HORA: El servicio $SERVICE_SSL esta detenido." | mail -s "Alerta de servicio del servidor $HOSTNAME" $EMAILS
#fi

# Verificar las respuestas a los sitios
#IP_SERVER=52.10.22.143

# Sitio Web
#URL_app=$IP_SERVER":8080/"

#if curl --output /dev/null --silent --head --fail "$URL_app"
#then
#        echo "OK, sitio funcionando"
#else
#        echo "Alerta: el sitio web no esta respondiendo, verificar el puerto 8080"
#        echo  "$FECHA_HORA Alerta: el sitio web no esta respondiendo, verificar el puerto 8080" | mail -s "Alerta: Problema con el sitio web"  $EMAILS
#fi

# Sitio Web de Administracion de Glassfish
#URL_admin=$IP_SERVER":4848/"

#if curl --output /dev/null --silent --head --fail "$URL_admin"
#then
#        echo "OK, sitio de administracion funcionando"
#else
#        echo "$FECHA_HORA Alerta: el sitio web no esta respondiendo, verificar el puerto 4848"
#        echo  "Alerta: el sitio web para administracion de glassfish no esta respondiendo, verificar el puerto 4848" | mail -s "Alerta: Problema con el sitio web de administracion"  $EMAILS
#fi

# Sitio Apache
#URL_apache=$IP_SERVER":80/"

#if curl --output /dev/null --silent --head --fail "$URL_apache"
#then
#        echo "OK, sitio por el puerto apache 80 funcionando"
#else
#        echo "$FECHA_HORA Alerta: el sitio web no esta respondiendo por el puerto de apache, verificar el puerto 80"
#        echo  "Alerta: el sitio web no esta respondiendo por el puerto de apache, verificar el puerto 80" | mail -s "Alerta: Problema con el sitio web" $EMAILS
#fi

# Enviar todos los email en cola
postqueue -p


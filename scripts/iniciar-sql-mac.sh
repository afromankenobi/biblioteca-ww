#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker info >/dev/null 2>&1 || { echo 'Comprueba que Docker esté instalado y su motor esté activo.'; exit 1; }
if [[ ! -f .env ]]; then
  # Al trabajar desde el Mac no es necesario publicar SQL en la red local.
  # Para una VM Windows en red puente, especificar la IP privada del Mac.
  BIBLIOTECA_BIND_IP="${BIBLIOTECA_BIND_IP:-127.0.0.1}"
  if [[ ! "$BIBLIOTECA_BIND_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo 'La dirección de enlace debe ser una IPv4.'; exit 1
  fi
  case "$BIBLIOTECA_BIND_IP" in
    127.0.0.1|10.*|192.168.*|172.1[6-9].*|172.2[0-9].*|172.3[01].*) ;;
    *) echo 'Usa una dirección privada de laboratorio para el puerto SQL.'; exit 1 ;;
  esac
  umask 077
  printf 'MSSQL_SA_PASSWORD=Bibl1_%s\nBIBLIOTECA_BIND_IP=%s\n' "$(openssl rand -hex 24)" "$BIBLIOTECA_BIND_IP" > .env
fi
BIBLIOTECA_BIND_IP="$(sed -n 's/^BIBLIOTECA_BIND_IP=//p' .env)"
mkdir -p evidencias/sql
echo 'Iniciando SQL Server Developer para el laboratorio...'
docker compose up -d
ready=0
for attempt in $(seq 1 90); do
  if docker compose exec -T sqlserver /bin/sh -c 'SQLCMDPASSWORD="$MSSQL_SA_PASSWORD" /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C -b -Q "SELECT 1"' >/dev/null 2>&1; then
    ready=1; break
  fi
  sleep 2
done
if [[ "$ready" != 1 ]]; then
  docker compose logs --no-color --tail 100 sqlserver > evidencias/sql/arranque-error.txt
  echo 'SQL Server no inició correctamente. Revisa evidencias/sql/arranque-error.txt.'
  echo 'En Mac ARM la imagen usa emulación x64, un entorno no soportado oficialmente por Microsoft.'
  exit 1
fi
docker compose exec -T sqlserver /bin/sh -c 'SQLCMDPASSWORD="$MSSQL_SA_PASSWORD" /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C -b -i /workspace/sql/01-crear-biblioteca.sql'
docker compose exec -T sqlserver /bin/sh -c 'SQLCMDPASSWORD="$MSSQL_SA_PASSWORD" /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C -b -i /workspace/sql/02-verificar-biblioteca.sql' > evidencias/sql/verificacion-inicial.txt
printf '{"server":"%s,14333","database":"BibliotecaDB","status":"ready"}\n' "$BIBLIOTECA_BIND_IP" > evidencias/sql/conexion.json
echo "BibliotecaDB lista. Servidor de conexión: $BIBLIOTECA_BIND_IP,14333"
echo 'La contraseña administrativa aleatoria se conserva en .env y no debe publicarse.'

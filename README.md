# alura-grafana-prometheus
Curso da Alura sobre Grafana com Prometheus. <https://unibb.alura.com.br/course/observabilidade-prometheus>

## Programas utilizados
- Grafana (Container, Interface para visualização dos dados).
- Docker
- Docker-compose
- JDK

## Instruções

### Subir as dependências
- Subir os containers via docker-compose `docker-compose up`.
  - Caso o Prometheus não suba, adicione permissão geral na pasta *prometheus_data* através do comando `chmod 777 prometheus/prometheus_data`.
- Compilar a aplicação `./mvnw clean package` e subi-la `bash start.sh`.

## Prometheus

### Tipos de dados
- Instant Vector: São os índices do array. Ex:
  - `logback_events_total{application="app-forum-api", instance="app-forum-api:8080", job="app-forum-api", level="info"}` : Logs Info;
  - `logback_events_total{application="app-forum-api", instance="app-forum-api:8080", job="app-forum-api", level="debug"}` : Logs Debug;
- Range Vector: São os tempos. Ex:
  - `logback_events_total[1m]` : Último 1 minuto;
  - `logback_events_total[5m]` : Últimos 5 minutos;

### Tipos de métricas
- Counter: Contador, crescente sempre aumenta. Se a aplicação resetar, o valor da métrica é zerado. Ex:
  - `auth_user_errors_total` : Contador de erros.
- Gauge: Valor aumenta ou diminui, varia. Ex:
  - `system_cpu_usage` : Uso do CPU.
- Histogram: Valor é agrupado e acumulado. Ex:
  - `http_server_requests_seconds_bucket{application="app-forum-api",exception="None",method="GET",outcome="SUCCESS",status="200",uri="/topicos/{id}",le="0.05",}` : Requisições que duraram menos ou igual a 50 milissegundos (0,05);
  - `http_server_requests_seconds_count{application="app-forum-api",exception="None",method="GET",outcome="SUCCESS",status="200",uri="/topicos/{id}",}` : Quantidade de requisições;
  - `http_server_requests_seconds_sum{application="app-forum-api",exception="None",method="GET",outcome="SUCCESS",status="200",uri="/topicos/{id}",}` : Somatório do tempo das requisições;
- Summary: Igual ao Histogram, porém mais utilizado para durações.

### Operações
- `http_server_requests_seconds_count{application="app-forum-api", method=~"GET|POST", status!~"2..|3..", uri!="/actuator/prometheus"} offset 1m`.
  - `~` e `|` : Um *OU*.
  - `!` : Negação.
  - `.` : Qualquer valor.
  - `offset` : Pega o último determinado tempo.
- `increase(http_server_requests_seconds_count{application="app-forum-api", uri!="/actuator/prometheus"}[1m])` : Agrupando para mostrar a quantidade de aumento das requisições;
- `sum(increase(http_server_requests_seconds_count{application="app-forum-api", uri!="/actuator/prometheus"}[1m]))` : Somando todas as requisições para mostrar o aumento delas;
- `irate(http_server_requests_seconds_count{application="app-forum-api", uri!="/actuator/prometheus"}[5m])` : Quantidade de requisições por segundo. utiliza os dois últimos valores;

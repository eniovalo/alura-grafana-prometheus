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
  - Adicione permissão geral na pasta *grafana* através do comando `chmod 777 grafana`.
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

## Grafana
Login:
- Usuário: admin
- Senha: admin

### Datasource
1. Configuration.
1. Datasource.
1. Add Prometheus.
    - URL: http://prometheus-forum-api:9090

### Dashboard
Criar Dashboard:
1. Create
1. Folder
    - forum-api
1. New Dashboard.
    - Dashboard settings.
    - dash-forum-api.
    - copy tags.

Criar variável *application*:
1. Dashboard settings.
    - Variables.
    - Name: application.
    - Type: Query.
    - Label: application.
    - Datasource: Prometheus.
    - Query: label_values(application)

Criar variável *instance*:
1. Dashboard settings.
    - Variables.
    - Name: instance.
    - Type: Query.
    - Label: instance.
    - Datasource: Prometheus.
    - Query: label_values(jvm_classes_loaded_classes{application="$application"}, instance)

Criar variável *pool*:
1. Dashboard settings.
    - Variables.
    - Name: pool.
    - Type: Query.
    - Label: pool.
    - Datasource: Prometheus.
    - Query: label_values(hikaricp_connections{instance="$instance", application="$application"}, pool)

Adicionar linha:
1. Add panel.
1. Add a new row.
    - API BASIC.

Adicionar painel Tempo em execução:
1. Add panel.
1. Add an empty panel.
    - Query:
        - Metrics: `process_uptime_seconds{application="$application",instance="$instance",job="app-forum-api"}`
    - Visualization: Stat.
        - Title: UPTIME.
        - Description: API runtime.
        - Graph mode: None.
        - Unit: duration (hh:mm:ss).

Adicionar painel Horário de Inicialização:
1. Add panel.
1. Add an empty panel.
    - Query:
        - Metrics: `process_start_time_seconds{application="$application",instance="$instance",job="app-forum-api"}*1000`
    - Visualization: Stat.
        - Title: START TIME.
        - Description: Hora da inicialização.
        - Graph mode: None.
        - Unit: Datetime local (No date if today).

Adicionar painel Log:
1. Add panel.
1. Add an empty panel.
    - Query 1:
        - Metrics: `sum(increase(logback_events_total{application="app-forum-api",instance="app-forum-api:8080",job="app-forum-api",level="warn"}[5m]))`
        - Legend: `warn` ou `{{level}}`
    - Query 2:
        - Metrics: `sum(increase(logback_events_total{application="app-forum-api",instance="app-forum-api:8080",job="app-forum-api",level="error"}[5m]))`
        - Legend: error
    - Visualization: Time series.
        - Title: WARN & ERROR LOG.
        - Description: Warnings e erros logados nos últimos 5 minutos.
        - Legend mode: Table.
        - Legend value: Min, Max, Last*, Total.
        - Unit: short.
        - Decimals: 0.

Adicionar painel Conexão JDBC:
1. Add panel.
1. Add an empty panel.
    - Query 1:
        - Metrics: `hikaricp_connections{application="$application",instance="$instance",job="app-forum-api",pool="$pool"}`
    - Visualization: stat.
        - Title: JDBC POOL.
        - Description: Pool de conexões JDBC.
        - Graph mode: None.
        - Unit: short.
        - Decimals: 0.
        - Thresholds: 10

Adicionar painel Usuário Logado:
1. Add panel.
1. Add an empty panel.
    - Query 1:
        - Metrics: `increase(auth_user_success_total[1m])`
    - Visualization: stat.
        - Title: USERS LOGGED.
        - Description: Usuários logados no último minuto.
        - Graph mode: None.
        - Unit: short.
        - Decimals: 0.

Adicionar painel Erros de autenticação:
1. Add panel.
1. Add an empty panel.
    - Query 1:
        - Metrics: `increase(auth_user_errors_total[1m])`
    - Visualization: stat.
        - Title: AUTH ERRORS.
        - Description: Erros de autenticação no último minuto.
        - Graph mode: None.
        - Unit: short.
        - Decimals: 0.
        - Thresholds: 5 | 10

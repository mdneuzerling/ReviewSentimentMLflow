# Call this in a separate process to not pollute the namespace here
callr::r(function() {
  drake::clean()
  devtools::load_all()
  drake::make(training_plan())
  drake::drake_history()
})

default_host <- "127.0.0.1"
default_port <- 8090

mlflow_daemon <- mlflow::mlflow_rfunc_serve(
  model_uri = "artefacts/model",
  host = default_host,
  port = default_port,
  daemonized = FALSE
)

request <- httr::POST(
  url = "http://127.0.0.1",
  port = default_port,
  path = "predict",
  body = "This is a good phone, I love it!"
)

httr::status_code(request)
httr::content(request)


httpuv::stopDaemonizedServer(mlflow_daemon)

import logging
import azure.functions as func

app = func.FunctionApp()

@app.function_name(name="HttpTrigger1")
@app.route(route="hello", auth_level=func.AuthLevel.ANONYMOUS)
def http_trigger(req: func.HttpRequest) -> func.HttpResponse:
    """
    Simple HTTP trigger function that returns a greeting message.
    Access via: https://<your-function-app>.azurewebsites.net/api/hello
    """
    logging.info('Python HTTP trigger function processed a request.')

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        return func.HttpResponse(
            f"Hello, {name}! This is your Azure Function App running successfully!",
            status_code=200
        )
    else:
        return func.HttpResponse(
            "Hello! This is your Azure Function App. Pass a name in the query string or in the request body for a personalized response.",
            status_code=200
        )

@app.function_name(name="TimerTrigger1")
@app.schedule(schedule="0 */5 * * * *", arg_name="myTimer", run_on_startup=False,
              use_monitor=False)
def timer_trigger(myTimer: func.TimerRequest) -> None:
    """
    Timer trigger that runs every 5 minutes.
    Useful for scheduled tasks, cleanup jobs, etc.
    """
    utc_timestamp = myTimer.utc_now.isoformat()
    logging.info(f'Python timer trigger function executed at UTC: {utc_timestamp}')
    logging.info('This function runs every 5 minutes.')

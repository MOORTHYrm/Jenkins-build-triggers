import os
import socket
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return f"""
    <html>
    <body style="font-family:Arial;text-align:center;margin-top:80px;">
      <h1>Simple App on Kubernetes</h1>
      <p>Version: {os.getenv('APP_VERSION', 'v1')}</p>
      <p>Served by pod: <b>{socket.gethostname()}</b></p>
    </body>
    </html>
    """

@app.route("/health")
def health():
    return "ok"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)


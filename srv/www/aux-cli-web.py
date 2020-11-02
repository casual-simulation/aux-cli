from flask import Flask, request
import subprocess
 
app = Flask(__name__)
 
@app.route('/post', methods = ["POST"])
def post():
    # Connect the bluetooth serial device
    if request.data.decode('utf-8') == "connect":
        subprocess.call('/bin/bt-serial-connect')

    # Disconnect the bluetooth serial device
    if request.data.decode('utf-8') == "disconnect":
        subprocess.call('/bin/bt-serial-disconnect')

    return ''
 
app.run(host='0.0.0.0', port= 8090)
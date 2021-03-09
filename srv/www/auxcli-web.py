from flask import Flask, request
import json
import subprocess
 
app = Flask(__name__)
 
@app.route('/post', methods = ["POST"])
def post():

    data = json.loads(request.data)
    command = data['command']
    device = data['device']
    mac = data['mac']
    channel = data['channel']

    # Connect the bluetooth serial device
    if command == "connect":
        subprocess.call(['/lib/auxcli/helper/bt-serial-connect', device, mac, channel])

    # Disconnect the bluetooth serial device
    if command == "disconnect":
        subprocess.call(['/lib/auxcli/helper/bt-serial-connect', device])

    return ''
 
app.run(host='0.0.0.0', port= 8090)
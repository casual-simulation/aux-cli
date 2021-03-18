from flask import Flask, request
import json
import subprocess
 
app = Flask(__name__)
 
@app.route('/post', methods = ["POST"])
def post():

    data = json.loads(request.data)
    command = (data['command'])

    # Connect the bluetooth serial device
    if command == "connect":
        device_c = (data['device'])
        mac = (data['mac'])
        channel = (data['channel'])
        subprocess.call(['/usr/bin/timeout', '60s', '/lib/auxcli/commands/helper/bt-serial-connect', device_c, mac, channel])

    # Disconnect the bluetooth serial device
    if command == "disconnect":
        device_d = (data['device'])
        subprocess.call(['/lib/auxcli/commands/helper/bt-serial-disconnect', device_d])

    return ''
 
app.run(host='0.0.0.0', port= 8090)
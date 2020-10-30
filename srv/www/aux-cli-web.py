from flask import Flask, request
import subprocess
 
app = Flask(__name__)
 
@app.route('/post', methods = ["POST"])
def post():
    if request.data.decode('utf-8') == "connect":
        subprocess.call('/bin/bt-serial-connect')
    return ''
 
app.run(host='0.0.0.0', port= 8090)
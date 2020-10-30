from flask import Flask, request
 
app = Flask(__name__)
 
@app.route('/post', methods = ["POST"])
def post():
    if request.data == "connect":
        os.system('/usr/bin/env bash /bin/bt-serial-connect')
    return ''
 
app.run(host='0.0.0.0', port= 8090)
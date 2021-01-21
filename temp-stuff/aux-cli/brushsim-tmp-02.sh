

const SerialPort = require('serialport')
const port = new SerialPort('/dev/rfcomm0', {
 baudRate: 9600
});

// Switches the port into "flowing mode"
port.on('data', function (data) {
  console.log('Data:', data)
})

############################################################



const SerialPort = require('serialport')
const port = new SerialPort('/dev/rfcomm0', {
 baudRate: 9600
});

port.open(function () {
 console.log('open');
 port.on('data', function(data) {
   var buff = new Buffer(data, 'utf8');
  console.log(buff.toString().replace(/(\r\n|\n|\r)/gm,""));
 });  
});


############################################################

var SerialPort = require('serialport');

var MYport;

SerialPort.list(function (err, ports) {
  ports.forEach(function(port) {
    if(port.vendorId == 9999){
      console.log('Found It')
      MYport = port.comName.toString();
      console.log(MYport);
    }
  });

  var port = new SerialPort(MYport, {
    parser: SerialPort.parsers.readline('\n')
  });

});


############################################################


var execSync = require('child_process').execSync;
var macAddress = "00:06:66:B9:08:36";

function detectMacAddressSync(address)
{
    var cmd = 'sudo rfcomm connect /dev/rfcomm0 ' + address + ' 1 &';
    try
    {
        var output = execSync(cmd );
        console.log("output : "+ output );
        return true;
    }
    catch(e)
    {
        console.log("caught: " + e);
        return false;
    }
}

detectMacAddressSync(macAddress);

############################################################

var macAddress = "00:06:66:B9:08:36";
require('child_process').execSync(
    'sudo rfcomm connect /dev/rfcomm0 ' + macAddress + ' 1 &',
    {stdio: 'inherit'}
);


const SerialPort = require('serialport')
const port = new SerialPort('/dev/rfcomm0', {
 baudRate: 9600
});

port.open(function () {
 console.log('open');
 port.on('data', function(data) {
   var buff = new Buffer(data, 'utf8');
  console.log(buff.toString().replace(/(\r\n|\n|\r)/gm,""));
 });  
});

############################################################
while [[ $(sudo hcitool auth 00:06:66:B9:08:36) == "Not Connected" ]]; do sleep 1; echo "Not Connected"; done


var macAddress = "00:06:66:B9:08:36";
const execSync = require('child_process').execSync;
const SerialPort = require('serialport')

async function bluetoothConnect(){
  try{
    execSync(
        'sudo rfcomm connect /dev/rfcomm0 ' + macAddress + ' 1 &',
        {shell: '/bin/bash', stdio: 'inherit'}
    );
    return true;
  } catch(e) {
        console.log("caught: " + e);
        return false;
    }
}

async function bluetoothPortCreate(){
  try{
    const port = new SerialPort('/dev/rfcomm0', {
      baudRate: 9600
    });
    return true;
  } catch(e) {
        console.log("caught: " + e);
        return false;
    }
}

async function bluetoothPortOpen(){
  try{
    port.open(function () {
      port.on('data', function(data) {
        var buff = new Buffer(data, 'utf8');
        console.log(buff.toString().replace(/(\r\n|\n|\r)/gm,""));
      });  
    });
    return true;
  } catch(e) {
        console.log("caught: " + e);
        return false;
    }
}

bluetoothConnect();
bluetoothPortCreate();
bluetoothPortOpen();

############################################################


var macAddress = "00:06:66:B9:08:36";
const execSync = require('child_process').execSync;
const SerialPort = require('serialport')
const parsers = SerialPort.parsers

execSync(
    'sudo rfcomm connect /dev/rfcomm0 ' + macAddress + ' 1',
    {shell: '/bin/bash', stdio: 'inherit'}
);

// Use a `\r\n` as a line terminator
const parser = new parsers.Readline({
  delimiter: '\r\n',
})

const port = new SerialPort('/dev/rfcomm0', {
  baudRate: 9600,
})

port.pipe(parser)
port.on('open', () => console.log('Port open'))
parser.on('data', console.log)



############################################################

const exec = require('child_process').exec;
const SerialPort = require('serialport')
const parsers = SerialPort.parsers

var macAddress = exec(
    '. /etc/bt-serial.conf; echo $device01_mac',
    {shell: '/bin/bash'}
).toString('utf8').replace(/(\r\n|\n|\r)/gm,"");

exec(
    'sudo rfcomm connect /dev/rfcomm0 ' + macAddress + ' 1 &',
    {shell: '/bin/bash', stdio: 'inherit'}
);

// Use a `\r\n` as a line terminator
const parser = new parsers.Readline({
  delimiter: '\r\n',
})

const port = new SerialPort('/dev/rfcomm0', {
  baudRate: 9600,
})

port.pipe(parser)
port.on('open', () => console.log('Port open'))
parser.on('data', console.log)



############################################################
sudo rfcomm connect /dev/rfcomm0 00:06:66:B9:08:36 1 & > ~/serialtests/rfcomm.log &
( tail -f -n0 logfile.log & ) | grep -q "Server Started"

const execSync = require('child_process').execSync;
const SerialPort = require('serialport')
const parsers = SerialPort.parsers

var macAddress = execSync(
    '. /etc/bt-serial.conf; echo $device01_mac',
    {shell: '/bin/bash'}
).toString('utf8').replace(/(\r\n|\n|\r)/gm,"");

execSync(
    'sudo rfcomm connect /dev/rfcomm0 ' + macAddress + ' 1 &',
    {shell: '/bin/bash', stdio: 'inherit'}
);

execSync(
    'while !(sudo rfcomm -a | grep "' + macAddress + '"); do sleep 1; echo "Not Connected Yet."; done',
    {shell: '/bin/bash', stdio: 'inherit'}
);

// Use a `\r\n` as a line terminator
const parser = new parsers.Readline({
  delimiter: '\r\n',
})

const port = new SerialPort('/dev/rfcomm0', {
  baudRate: 9600,
})

port.pipe(parser)
port.on('open', () => console.log('Port open'))
parser.on('data', console.log)



############################################################

curl -X POST ‘http://localhost:8090/post’ -H ‘Content-type: text/plain’ --data ‘connect’

curl -X POST -H "Content-Type: text/plain" --data "connect" http://localhost:8090/post



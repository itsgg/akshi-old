// XXX: Make it scalable
var npid = require('npid');
var argv = require('optimist').argv;
var fs = require('fs');
var syncData = {};

try {
    if(fs.existsSync(argv.pidfile)) {
        fs.unlinkSync(argv.pidfile);
    }
    npid.create(argv.pidfile);
} catch(err) {
    console.log(err);
    process.exit(1);
}

var server;

if(argv.secure) {
    var fs = require('fs');
    var options = {
        key: fs.readFileSync('/u/apps/akshi/shared/keys/akshi.key'),
        cert: fs.readFileSync('/u/apps/akshi/shared/keys/akshi.pem')
    };
    server = require('https').createServer(options).listen(9000);
} else {
    server = require('http').createServer().listen(9000);
}

var io = require('socket.io').listen(server);
io.configure(function() {
    io.set('transports', ['websocket', 'flashsocket',
                          'xhr-polling', 'jsonp-polling',
                          'htmlfile']);
    io.set('authorization', function(handshakeData, callback) {
        if(handshakeData.query.token === '6e16a2a41c2733c15124fcfcf3b6b00d') {
            callback(null, true);
        } else {
            callback(null, false);
        }
    });
});

if(argv.d) {
    io.set('log level', 0);
} else {
    io.enable('browser client minification');
    io.enable('browser client etag');
    io.enable('browser client gzip');
    io.set('log level', 1);
}

io.sockets.on('connection', function(socket) {
    socket.on('subscribe', function(data) {
        socket.room = data.room;
        socket.join(data.room);
        socket.emit('live-sync', syncData[data]);
    });

    socket.on('unsubscribe', function(data) {
        socket.leave(data.room);
    });

    ['chat', 'presentation', 'whiteboard'].forEach(function(eventName) {
        socket.on(eventName, function(data) {

            // Initialize the client storage
            if(eventName == 'presentation' || eventName == 'whiteboard') {
                if(!syncData[data.courseId]) {
                    syncData[data.courseId] = {
                        lastSlide: "",
                        lastPoints: [],
                        totalSlides: 0,
                        fileType: null,
                        lessonId: ""
                    };
                }
            }

            if(eventName == 'presentation') {
                if(data.type == 'show') {
                    if (data.url != '')
                        urlLength = data.url.split('.').length
                    else
                        urlLength = 2
                    urlExtension = data.url.split('.')[urlLength - 1]
                    syncData[data.courseId].fileType = urlExtension;
                    if (urlExtension == 'png'){
                        syncData[data.courseId].totalSlides = data.totalSlides;
                        syncData[data.courseId].lessonId = data.lessonId;
                        syncData[data.courseId].lastSlide = data.url;
                    }
                }
                if(data.type == 'hide') {
                    syncData[data.courseId].fileType = "";
                    syncData[data.courseId].lastSlide = "";
                    syncData[data.courseId].totalSlides = 0;
                    syncData[data.courseId].lessonId = null;
                }
            }

            if(eventName == 'whiteboard') {
                if(data.type == 'draw' && data.data) {
                    syncData[data.courseId].lastPoints = syncData[data.courseId].lastPoints.concat(data.data.points);
                }
                if(data.type == 'clear') {
                    syncData[data.courseId].lastPoints = [];
                }
            }
            socket.broadcast.to(socket.room).emit(eventName, data);
        });
    });
});

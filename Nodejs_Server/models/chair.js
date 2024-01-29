var mongoose = require('mongoose')
const {version} = require("nodemon/lib/utils");
var Schema= mongoose.Schema;

// Chair Model Schema
var chairSchema = new Schema({
    serial: {
        type: String,
        require: false
    },
    status: {
        type: Number,
        require: false
    },
    eventId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Event',
        require: true
    },
    emergency: [{
        type: Number,
        require: true
    }],
    lat: {
        type: String,
        require: false
    },
    long: {
        type: String,
        require: false
    },
    blue: {
        type: Number,
        require: false
    },
    sim: {
        type: String,
        require: false
    }

}, {
    versionKey: false
});

module.exports = mongoose.model('Chair', chairSchema)
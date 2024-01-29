var mongoose = require('mongoose')
var Schema= mongoose.Schema;

// Control Model Schema
var eventSchema = new Schema({
    temperature: {
        type: Number,
        require: false
    },
    humidity: {
        type: Number,
        require: false
    },
    seat: {
        type: Number,
        require: false
    },
    belt: {
        type: Number,
        require: false
    },
    car: {
        type: Number,
        require: false
    },
    timestamp: {
        type:Number,
        require:false
    }

},{
    versionKey: false
});

module.exports = mongoose.model('Event', eventSchema)
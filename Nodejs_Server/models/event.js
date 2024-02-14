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
    lat: {
        type: Number,
        require: false
    },
    long: {
        type: Number,
        require: false
    },
    blue: {
        type: Number,
        require: false
    },
    chairId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Chair',
        require: true
    },
    timestamp: {
        type:Number,
        require:false
    }

},{
    versionKey: false
});

module.exports = mongoose.model('Event', eventSchema)
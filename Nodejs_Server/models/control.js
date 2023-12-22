var mongoose = require('mongoose')
var Schema= mongoose.Schema;

// Control Model Schema
var controlSchema = new Schema({
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
    }

});

module.exports = mongoose.model('Control', controlSchema)
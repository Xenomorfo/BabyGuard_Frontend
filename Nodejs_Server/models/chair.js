var mongoose = require('mongoose')
var Schema= mongoose.Schema;

// Chair Model Schema
var chairSchema = new Schema({
    serial: {
        type: Number,
        require: false
    },
    status: {
        type: Number,
        require: false
    },
    controlId: {
        type: mongoose.Schema.Types.ObjectId,
        ref:'Control',
        require: true
    }
});

module.exports = mongoose.model('Chair', chairSchema)
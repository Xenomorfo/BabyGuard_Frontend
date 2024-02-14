var User = require('../models/user')
var Chair = require('../models/chair')
var Event = require('../models/event')
var jwt = require('jwt-simple')
var config = require('../config/dbconfig')
var nodemailer = require('nodemailer');
const {populate, options} = require("mongoose/lib/utils");
const e = require("express");

var functions = {
    // Novo Utilzador
    addNew: function (req, res) {
        User.findOne({
                email: req.body.email
            }, async function (err, user) {
                    if (err) throw err
                    if (user) {
                        res.status(403).send({success: false, msg: 'Already taken'})


                } else
                {
                    var newChair = Chair({
                        serial: 0,
                        status: 0,
                        emergency: [req.body.contact, 0, 0],
                        sim: '0000'
                    });
                    var newEvent = Event({
                        temperature: 0,
                        humidity: 0,
                        seat: 0,
                        belt: 0,
                        car: 1,
                        lat: 38.7324,
                        long: -9.1567,
                        blue: 1,
                        chairId: newChair._id,
                        timestamp: Date.now()

                    });


                    var newUser = User({
                        name: req.body.name,
                        email: req.body.email,
                        contact: req.body.contact,
                        password: req.body.password,
                        chairId: newChair._id
                    });

                try {
                    newUser.save();
                    newChair.save();
                    newEvent.save();
                    res.json({success: true, msg: 'Successfully saved'})
                } catch {
                    res.json({success: false, msg: 'Failed to save'})

                }
            
            }
    }
        )
    },
    // Autênticação
    authenticate: function (req, res) {
        User.findOne({
            email: req.body.email
        }, function (err, user) {
                if (err) throw err
                if (!user) {
                    res.status(403).send({success: false, msg: 'User not found'})
                }

                else {
                    user.comparePassword(req.body.password, function (err, isMatch) {
                        if (isMatch && !err) {
                            var token = jwt.encode(user, config.secret)
                            User.findOne(user._id)
                                .populate({path: 'chairId'})
                                .exec(function (err, user) {
                                    const id = user._id;
                                    const name =  user.name;
                                    const email = user.email;
                                    const contact = user.contact;
                                    const password = user.password;
                                    Chair.findOne(user.chairId)
                                        .populate({path: 'chairId'})
                                        .exec(function (err, chair) {
                                            res.json({
                                                success: true,
                                                token: token,
                                                id: id,
                                                name: name,
                                                email: email,
                                                contact: contact,
                                                password: password,
                                                serial: chair.serial,
                                                emergency_1: chair.emergency["0"],
                                                emergency_2: chair.emergency["1"],
                                                emergency_3: chair.emergency["2"],
                                                sim: chair.sim
                                            })
                                        })
                                })
                        }
                            else {
                                return res.status(403).send({success: false, msg: 'Wrong password'})
                            }
                    })
                }
        }
        )
    },
    // Informação
    getinfo: function (req, res) {
        if (req.headers.authorization && req.headers.authorization.split(' ')[0] === 'Bearer') {
            var token = req.headers.authorization.split(' ')[1]
            var decodedtoken = jwt.decode(token, config.secret)
            User.findOne(req.body._id)
                .populate({path: 'chairId'})
                .exec(function(err,chairs) {
                    Chair.findOne(chairs.eventId)
                        .populate({path:'eventId'})
                        .exec(function (err,events) {
                            console.log(events.temperature)
                            return res.json({success: true, msg: 'Hello ' + events, temperature: events.temperature})
                        })
                })


            //return res.json({success: true, msg: 'Hello ' + decodedtoken.name})

        }
        else {
            return res.sendStatus(403);
            //return res.json({success: false, msg: 'No Headers'})
        }
    },
    // Ver Dashboard
    dashboard: function (req, res) {
        if (req.headers.authorization && req.headers.authorization.split(' ')[0] === 'Bearer') {
            var token = req.headers.authorization.split(' ')[1]
            var decodedtoken = jwt.decode(token, config.secret)
            User.findOne({
                email: decodedtoken.email
            }, function (err, user) {
                if (err) throw err
                if (!user) {
                    res.status(403).send({success: false, msg: 'User not found'})
                } else {
                    User.findOne(user._id)
                        .populate({path: 'chairId'})
                        .exec(function (err, chair) {
                            const serial = chair.chairId.serial;
                            const sim = chair.chairId.sim;
                            Event.findOne({chairId: user.chairId})
                                .populate({path: 'eventId'})
                                .sort({timestamp: -1})
                                .limit(1)
                                .exec(function (err, events) {
                                    return res.json({
                                        success: true,
                                        serial: serial,
                                        sim: sim,
                                        events: events
                                    })

                                })
                        })
                }
                //return res.json({success: true, msg: 'Hello ' + decodedtoken.email})
            })
            }
        },

        // Ver Historico
        history: function (req, res) {
            if (req.headers.authorization && req.headers.authorization.split(' ')[0] === 'Bearer') {
                var token = req.headers.authorization.split(' ')[1]
                var decodedtoken = jwt.decode(token, config.secret)
                User.findOne({
                    email: decodedtoken.email
                }, function (err, user) {
                    if (err) throw err
                    if (!user) {
                        res.status(403).send({success: false, msg: 'User not found'})
                    } else {
                        User.findOne(user._id)
                            .populate({path: 'chairId'})
                            .exec(function (err, chair) {
                                Event.find({chairId: user.chairId})
                                    .populate({path: 'eventId'})
                                    .exec(function (err, events) {
                                        return res.json({
                                            success: true,
                                            events: events
                                        })

                                    })
                            })
                    }
                    //return res.json({success: true, msg: 'Hello ' + decodedtoken.email})
                })
            }

        else {
            return res.sendStatus(403);
            //return res.json({success: false, msg: 'No Headers'})
        }
    },
    // Atualizar Senha
    updatepass: function (req, res) {
        User.findOne({
            _id: req.body.id
        }, function (err, user) {
            if (err) throw err
            if (!user) {
                res.status(403).send({success: false, msg: 'User not found'})
            } else {
                user.password = req.body.password;
                user.save(function (err, user) {
                    if (err) {
                        res.json({success: false, msg: 'Failed to save'})
                    }
                    else {
                        res.json({success: true, msg: 'Successfully saved'})
                    }
                })
            }
        });
    },
    // Editar Perfil
    editprofile: function (req, res) {
        User.findOne({
            email: req.body.email
        }, function (err, user) {
            if (err) throw err
            if (!user) {
                res.status(403).send({success: false, msg: 'User not found'})
            } else {
                User.findOne(user._id)
                    .populate({path: 'chairId'})
                    .exec(function (err, users) {
                        users.email = req.body.email;
                        users.name = req.body.name;
                        users.contact = req.body.contact;
                        console.log(users);
                        Chair.findOne(users.chairId)
                            .exec(function (err, chair) {

                                chair.emergency.set("0", req.body.contact);
                                chair.serial = req.body.serial;
                                chair.save();

                            })
                        user.save(function (err, user) {
                            if (err) {
                                res.json({success: false, msg: 'Failed to save'})
                            } else {
                                res.json({success: true, msg: 'Successfully saved'})
                            }
                        })

                    });
            }
        });
    },
    // Editar Cadeira
    configchair: function (req, res) {
        User.findOne({
            email: req.body.email
        }, function (err, user) {
            if (err) throw err
            if (!user) {
                res.status(403).send({success: false, msg: 'User not found'})
            } else {
                User.findOne(user._id)
                    .populate({path: 'chairId'})
                    .exec(function (err, user) {
                        Chair.findOne(user.chairId)
                            .exec(function (err, chair) {
                                chair.serial = req.body.serial;
                                chair.emergency.set("0", req.body.contact_1);
                                chair.emergency.set("1", req.body.contact_2);
                                chair.emergency.set("2", req.body.contact_3);
                                chair.sim = req.body.sim;
                                chair.save(function (err, chair) {
                                    if (err) {
                                        res.json({success: false, msg: 'Failed to save'})
                                    } else {
                                        res.json({success: true, msg: 'Successfully saved'})
                                    }
                                })
                            });
                        });
                    }
                })
            },
    // Repor Senha
    passrequest: function (req, res) {
        User.findOne({
            email: req.body.email
        }, function (err, user) {
            if (err) throw err
            if (!user) {
                res.status(403).send({success: false, msg: 'User not found'})
            } else {
            var randomstring = Math.random().toString(36).slice(-8);
            user.password = randomstring;
                user.save(function (err, user) {
                    if (err) {
                        res.json({success: false, msg: 'Failed to save'})
                    }
                    else {
                        res.json({success: true, msg: 'Successfully saved'})
                        var transporter = nodemailer.createTransport({
                            host: 'smtp.sapo.pt',
                            port: 465,
                            secure: true,
                            auth: {
                                user: 'babyguard@sapo.pt',
                                pass: 'Password12345!'
                            }
                        });

                        var mailOptions = {
                            from: 'BabyGuard@sapo.pt',
                            to: req.body.email,
                            subject: 'BabyGuard Nova Senha',
                            text: 'A nova senha é: '+randomstring
                                +'\n\nAssim que fizer a autênticação, por razões de segurança, ' +
                                'altere a senha.\n\nObrigado,\n\nBabyGuard'
                        };

                        transporter.sendMail(mailOptions, function(error, info){
                            if (error) {
                                console.log(error);
                            } else {
                                console.log('Email sent: ' + info.response);
                            }
                        });
                    }
                })
            }
        });
    },

}

module.exports = functions
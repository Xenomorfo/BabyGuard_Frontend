var User = require('../models/user')
var Chair = require('../models/chair')
var Control = require('../models/control')
var jwt = require('jwt-simple')
var config = require('../config/dbconfig')
var nodemailer = require('nodemailer');
const {populate} = require("mongoose/lib/utils");

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
                    var newControl = Control({
                        temperature: 0,
                        humidity: 0,
                        seat: 0,
                        belt: 0

                    });
                    var newChair = Chair({
                            serial: 0,
                            status: 0,
                            controlId: newControl._id

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
                    newControl.save();
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
                            res.json({success: true, token: token, id: user._id, name: user.name, email: user.email, contact: user.contact, password: user.password})
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
            User.find()
                .populate({path: 'chairId'})
                .exec(function (err, docs){
                console.log(docs)
                return res.json({success: true, msg: 'Hello ' + docs})
            });
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
                } else return res.json({success: true, msg: 'Hello ' + decodedtoken.email})
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
            id: req.body.id
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
        },function (err, user) {
            if (err) throw err
            if (!user) {
                res.status(403).send({success: false, msg: 'User not found'})
            } else {
                user.email = req.body.email;
                user.name = req.body.name;
                user.contact = req.body.contact;
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
            console.log(randomstring);
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
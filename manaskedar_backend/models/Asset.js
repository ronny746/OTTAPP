const mongoose = require('mongoose');

const assetSchema = new mongoose.Schema({
    name: { type: String, required: true },
    url: { type: String, required: true },
    type: { type: String, enum: ['video', 'image', 'audio'], required: true },
    fileSize: { type: Number },
    duration: { type: String }, // For video/audio
    createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Asset', assetSchema);

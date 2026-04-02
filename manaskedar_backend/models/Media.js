const mongoose = require('mongoose');

const mediaSchema = new mongoose.Schema({
    title: { type: String, required: true },
    imageUrl: { type: String, required: true },
    videoUrl: { type: String },
    type: { type: String, enum: ['video', 'audio', 'short', 'movie', 'shorts', 'show'], required: true },
    description: { type: String, default: 'A mysterious story unfolding in the heart of the city...' },
    rating: { type: String, default: '4.5' },
    year: { type: String, default: '2024' },
    duration: { type: String, default: '2h 15m' },
    likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    shares: { type: Number, default: 0 },
    commentsCount: { type: Number, default: 0 },
    views: { type: Number, default: 0 },
    episodes: [{
        title: { type: String, required: true },
        videoUrl: { type: String, required: true },
        duration: { type: String, default: '30m' },
        description: { type: String },
        imageUrl: { type: String }, // episode-specific thumbnail
        order: { type: Number, default: 1 }
    }],
    createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Media', mediaSchema);

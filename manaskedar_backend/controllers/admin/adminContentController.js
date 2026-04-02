const User = require('../../models/User'); // For stats
const Media = require('../../models/Media');
const Banner = require('../../models/Banner');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

// Admin Analytics
exports.getDashboardStats = async (req, res) => {
    try {
        const [totalMedia, totalUsers, totalMovies, totalShorts, totalAudio, totalShows, recentUsers] = await Promise.all([
            Media.countDocuments(),
            User.countDocuments(),
            Media.countDocuments({ type: 'movie' }),
            Media.countDocuments({ type: { $in: ['shorts', 'short'] } }),
            Media.countDocuments({ type: 'audio' }),
            Media.countDocuments({ type: 'show' }),
            User.find().select('name createdAt').sort('-createdAt').limit(5)
        ]);

        res.status(200).json({
            media: totalMedia,
            users: totalUsers,
            movies: totalMovies,
            shorts: totalShorts,
            audio: totalAudio,
            shows: totalShows,
            recentUsers
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Media Library Overview
exports.getMedia = async (req, res) => {
    try {
        const media = await Media.find().sort('-createdAt');
        res.status(200).json(media);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Media CRUD
exports.createMedia = async (req, res) => {
    try {
        const media = await Media.create(req.body);
        res.status(201).json(media);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.updateMedia = async (req, res) => {
    try {
        const media = await Media.findByIdAndUpdate(req.params.id, req.body, { returnDocument: 'after' });
        res.status(200).json(media);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getUploadAuth = async (req, res) => {
    try {
        res.status(200).json({ local: true, endpoint: '/api/admin/upload' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.deleteMedia = async (req, res) => {
    try {
        await Media.findByIdAndDelete(req.params.id);
        res.status(200).json({ message: 'Deleted' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.createBanner = async (req, res) => {
    try {
        const banner = await Banner.create(req.body);
        res.status(201).json(banner);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.deleteBanner = async (req, res) => {
    try {
        await Banner.findByIdAndDelete(req.params.id);
        res.status(200).json({ message: 'Banner deleted' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.uploadFile = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }

        const isVideo = req.file.mimetype.startsWith('video/');
        const oldFilePath = req.file.path;
        
        if (isVideo) {
            console.log(`[FFMPEG] Starting FastStart optimization for: ${req.file.filename}`);
            try {
                // Optimization for Streaming (FastStart)
                // We rename original to .tmp, and output optimized to original filename
                const tmpPath = `${oldFilePath}.tmp`;
                fs.renameSync(oldFilePath, tmpPath);

                // Command to move moov atom to front without re-encoding (-c copy)
                // Using double quotes for Windows/Mac compatibility with spaces
                const command = `ffmpeg -i "${tmpPath}" -c copy -movflags +faststart "${oldFilePath}"`;
                
                await execPromise(command);
                
                // Cleanup tmp file
                if (fs.existsSync(tmpPath)) fs.unlinkSync(tmpPath);
                console.log(`[FFMPEG] Optimization complete: ${req.file.filename}`);
            } catch (ffmpegErr) {
                console.error('[FFMPEG ERROR] Optimization failed, using original file:', ffmpegErr.message);
                // In case of error, if we renamed it, try to restore it
                const tmpPathRestoration = `${oldFilePath}.tmp`;
                if (fs.existsSync(tmpPathRestoration) && !fs.existsSync(oldFilePath)) {
                    fs.renameSync(tmpPathRestoration, oldFilePath);
                }
            }
        }

        // Generate full URL for the file
        const protocol = req.protocol;
        const host = req.get('host');
        const fileUrl = `${protocol}://${host}/uploads/${req.file.filename}`;

        res.status(200).json({
            message: isVideo ? 'File uploaded and optimized for streaming' : 'File uploaded successfully',
            url: fileUrl,
            fileId: req.file.filename,
            fileType: req.file.mimetype.split('/')[0] 
        });
    } catch (err) {
        console.error('Upload Error:', err.message);
        res.status(500).json({ error: err.message });
    }
};

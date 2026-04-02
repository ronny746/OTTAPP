const Media = require('../../models/Media');
const Banner = require('../../models/Banner');

exports.getBanners = async (req, res) => {
    try {
        const banners = await Banner.find().populate('mediaId');
        res.status(200).json(banners);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getMedia = async (req, res) => {
    try {
        const { type, search } = req.query;
        let filter = {};
        if (type) filter.type = type;
        if (search) {
            filter.title = { $regex: search, $options: 'i' };
        }
        
        const media = await Media.find(filter);
        res.status(200).json(media);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

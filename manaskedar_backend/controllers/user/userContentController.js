const Media = require('../../models/Media');
const Banner = require('../../models/Banner');
const User = require('../../models/User');

exports.getBanners = async (req, res) => {
    try {
        const banners = await Banner.find().populate('mediaId');
        res.status(200).json(banners);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getHomeData = async (req, res) => {
    try {
        const userId = req.user.id;

        // 1. Fetch Featured (Banners)
        const banners = await Banner.find().populate('mediaId');

        // 2. Continue Watching (if history exists)
        const user = await User.findById(userId).populate({
            path: 'watchHistory.media',
            model: 'Media'
        });
        
        const continueWatchingItems = user ? user.watchHistory
            .filter(h => h.media != null)
            .sort((a, b) => b.updatedAt - a.updatedAt)
            .slice(0, 10)
            .map(h => {
                const m = h.media.toObject();
                m.id = m._id.toString(); 
                m.lastPosition = h.position;
                return m;
            }) : [];

        // 3. Categories (Requested Order: Continue, Maha Movie, Shows, Shorts, Audio)
        const movies = await Media.find({ type: { $in: ['movie', 'video'] } }).limit(10).sort('-createdAt');
        const shows = await Media.find({ type: { $in: ['show', 'video'] } }).limit(10).sort('-createdAt');
        const shorts = await Media.find({ type: { $in: ['short', 'shorts'] } }).limit(15).sort('-createdAt');
        const audio = await Media.find({ type: 'audio' }).limit(10).sort('-createdAt');

        // Build structured sections in EXACT requested order with Localization-friendly keys
        const sections = [
            { 
               title: 'continue_watching', 
               subtitle: 'resume_journey', 
               items: continueWatchingItems 
            },
            { 
                title: 'maha_movies', 
                subtitle: 'divine_cinema', 
                items: movies 
            },
            { 
               title: 'sattva_shows', 
               subtitle: 'divine_series', 
               items: shows 
            },
            { 
               title: 'ansh_shorts', 
               subtitle: 'divine_spark', 
               items: shorts 
            },
            { 
                title: 'nada_audio', 
                subtitle: 'divine_sound', 
                items: audio 
            }
        ];

        // Filter and ensure all items have a string ID
        const filteredSections = sections
            .filter(s => s.items && s.items.length > 0)
            .map(s => ({
                ...s,
                items: s.items.map(m => {
                    const item = (typeof m.toObject === 'function') ? m.toObject() : m;
                    item.id = item._id.toString();
                    return item;
                })
            }));

        res.status(200).json({
            banners,
            continueWatching: continueWatchingItems,
            sections: filteredSections
        });
    } catch (err) {
        console.error('Home Data Error:', err);
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

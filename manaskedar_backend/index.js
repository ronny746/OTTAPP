require('dotenv').config();
const User = require('./models/User');
const Media = require('./models/Media');
const Banner = require('./models/Banner');
const movieRoutes = require('./routes/admin/movieRoutes');
const showRoutes = require('./routes/admin/showRoutes');
const shortsRoutes = require('./routes/admin/shortsRoutes');
const audioRoutes = require('./routes/admin/audioRoutes');
const assetRoutes = require('./routes/admin/assetRoutes');
const adminRoutes = require('./routes/admin/adminRoutes');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/user/userRoutes');
const cors = require('cors');
const express = require('express');
const connectDB = require('./config/db');

connectDB();

const app = express();
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Admin Routes
app.use('/api/admin', adminRoutes);
app.use('/api/admin/movies', movieRoutes);
app.use('/api/admin/shows', showRoutes);
app.use('/api/admin/shorts', shortsRoutes);
app.use('/api/admin/audio', audioRoutes);
app.use('/api/admin/assets', assetRoutes);

// User/Auth Routes
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => {});

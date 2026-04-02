const express = require('express');
const router = express.Router();
const { protect, admin } = require('../../middleware/auth');
const adminCtrl = require('../../controllers/admin/adminContentController');

// Protecting all admin routes
router.use(protect, admin);

router.get('/media', adminCtrl.getMedia); // Library overview
router.post('/media', adminCtrl.createMedia);
router.put('/media/:id', adminCtrl.updateMedia);
router.delete('/media/:id', adminCtrl.deleteMedia);
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure 'uploads' directory exists
const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Set up disk storage for local uploads
const upload = multer({ 
    storage: multer.diskStorage({
        destination: (req, file, cb) => cb(null, 'uploads/'),
        filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname)
    }),
    limits: { fileSize: 50 * 1024 * 1024 * 1024 } // Set high limit (50GB) to effectively remove size restriction
});

const userMgmtCtrl = require('../../controllers/admin/userManagementController');

router.get('/upload-auth', adminCtrl.getUploadAuth);
router.post('/upload', upload.single('file'), adminCtrl.uploadFile);
router.get('/stats', adminCtrl.getDashboardStats);

// User Management
router.get('/users', userMgmtCtrl.getAllUsers);
router.get('/users/:id', userMgmtCtrl.getUserDetails);
router.put('/users/:id', userMgmtCtrl.updateUser);
router.delete('/users/:id', userMgmtCtrl.deleteUser);
router.patch('/users/:id/role', userMgmtCtrl.toggleAdmin);
router.patch('/users/:id/premium', userMgmtCtrl.togglePremium);

// Content management shortcuts
router.post('/banners', adminCtrl.createBanner);
router.delete('/banners/:id', adminCtrl.deleteBanner);

// Specific sub-routes
router.use('/movies', require('./movieRoutes'));
router.use('/shorts', require('./shortsRoutes'));
router.use('/audios', require('./audioRoutes'));
router.use('/shows', require('./showRoutes'));
router.use('/assets', require('./assetRoutes'));

module.exports = router;

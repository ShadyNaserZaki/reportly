import express from 'express';
import connectDB from './src/config/database.js';
import authRoutes from './src/routes/auth.route.js';

const app = express();
const port = 5000;

// Connect to database
connectDB().catch(err => {
    console.error('Database connection failed:', err);
    process.exit(1);
});

// Middleware
app.use(express.json());

// API Routes
app.use('/api/auth', authRoutes);

// Handle 404 - Route not found
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: `Route ${req.originalUrl} not found`
    });
});

// Global error handler
app.use((err, req, res, next) => {
    console.error(err);

    // Default to 500 server error
    const status = err.status || 500;
    const message = err.message || 'Something went wrong!';

    // Error response
    const errorResponse = {
        success: false,
        message,
    };

    res.status(status).json(errorResponse);
});

// Start server
app.listen(port, () => {
    console.log(`Server is running on port ${port} 🟢`);
});

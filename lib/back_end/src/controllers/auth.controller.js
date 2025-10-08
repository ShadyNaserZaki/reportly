import User from '../models/User.js';
import { UnauthorizedError, ConflictError } from '../utils/errors.js';

// Register new user
export const register = async (req, res, next) => {
    try {
        const validatedData = req.validatedData;

        // Check if user already exists
        const existingUser = await User.findOne({ email: validatedData.email });
        if (existingUser) {
            throw new ConflictError('User already exists with this email');
        }

        // Create new user
        const user = new User(validatedData);
        await user.save();

        // Generate token
        const token = user.generateAuthToken();

        res.status(201).json({
            success: true,
            data: {
                user: {
                    id: user._id,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    email: user.email,
                    role: user.role,
                    isActive: user.isActive
                },
                token
            }
        });
    } catch (error) {
        next(error);
    }
};

// Login user
export const login = async (req, res, next) => {
    try {
        const { email, password } = req.validatedData;

        // Check if user exists
        const user = await User.findOne({ email }).select('+password');
        if (!user) {
            throw new UnauthorizedError('Invalid credentials');
        }

        // Check if password matches
        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            throw new UnauthorizedError('Invalid credentials');
        }

        // Check if user is active
        if (!user.isActive) {
            throw new UnauthorizedError('Account is inactive. Please contact your administrator.');
        }

        // Generate token
        const token = user.generateAuthToken();

        res.json({
            success: true,
            data: {
                user: {
                    id: user._id,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    email: user.email,
                    role: user.role,
                    isActive: user.isActive
                },
                token
            }
        });
    } catch (error) {
        next(error);
    }
};

// Get current user
export const getMe = async (req, res, next) => {
    try {
        const user = await User.findById(req.user.id);
        if (!user) {
            throw new UnauthorizedError('User not found');
        }

        res.json({
            success: true,
            data: {
                user: {
                    id: user._id,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    email: user.email,
                    role: user.role,
                    isActive: user.isActive
                }
            }
        });
    } catch (error) {
        next(error);
    }
};
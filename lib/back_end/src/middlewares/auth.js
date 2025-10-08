import jwt from 'jsonwebtoken';
import User from '../models/User.js';
import { UnauthorizedError } from '../utils/errors.js';

export const auth = async (req, res, next) => {
    try {
        const token = req.header('Authorization')?.replace('Bearer ', '');

        if (!token) {
            throw new UnauthorizedError('Access denied. No token provided');
        }

        const decoded = jwt.verify(token, "jomlaMarketSoSecretKeyShh");
        const user = await User.findById(decoded.id);

        if (!user) {
            throw new UnauthorizedError('User no longer exists');
        }

        if (!user.isActive) {
            throw new UnauthorizedError('Account is inactive. Please contact your administrator.');
        }


        req.user = {
            id: user._id,
            role: user.role,
            isActive: user.isActive
        };

        next();
    } catch (error) {

        next(error);

    }
};
import { Router } from 'express';
import { register, login, getMe } from '../controllers/auth.controller.js';
import { auth } from '../middlewares/auth.js';
import { registerUserSchema, loginSchema } from '../validations/auth.validation.js';
import { validate } from '../middlewares/validate.js';

const router = Router();

router.post('/register',
    validate(registerUserSchema),
    register
);

router.post('/login', validate(loginSchema), login);

router.get('/me', auth, getMe);

export default router;